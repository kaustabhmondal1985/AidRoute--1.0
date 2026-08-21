import os
import time
from typing import List, Dict

from dotenv import load_dotenv
from supabase import create_client, Client

from .chunker import load_and_chunk_knowledge_base
from .embeddings import embed_document


# ---------------------------------------------------------
# Environment
# ---------------------------------------------------------

ENV_PATH = os.path.abspath(
    os.path.join(
        os.path.dirname(__file__),
        "..",
        "..",
        ".env",
    )
)

load_dotenv(ENV_PATH)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY")

if not SUPABASE_URL:
    raise RuntimeError("SUPABASE_URL not found in backend/.env")

if not SUPABASE_SERVICE_KEY:
    raise RuntimeError("SUPABASE_SERVICE_KEY not found in backend/.env")


# ---------------------------------------------------------
# Supabase Client
# ---------------------------------------------------------

supabase: Client = create_client(
    SUPABASE_URL,
    SUPABASE_SERVICE_KEY,
)


# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------

MAX_RETRIES = 3
RETRY_DELAY_SECONDS = 2


# ---------------------------------------------------------
# Supabase Upsert
# ---------------------------------------------------------

def _upsert_chunk(chunk: Dict) -> str:
    """
    Insert or update a knowledge chunk.

    Uniqueness is based on:
        source + chunk_index

    Returns:
        "inserted" or "updated"
    """

    source = chunk["source"]
    chunk_index = chunk["chunk_index"]

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            # Check whether the chunk already exists.
            existing = (
                supabase
                .from_("knowledge_chunks")
                .select("id")
                .eq("source", source)
                .eq("chunk_index", chunk_index)
                .limit(1)
                .execute()
            )

            existing_rows = existing.data or []

            if existing_rows:
                row_id = existing_rows[0]["id"]

                (
                    supabase
                    .from_("knowledge_chunks")
                    .update(chunk)
                    .eq("id", row_id)
                    .execute()
                )

                return "updated"

            (
                supabase
                .from_("knowledge_chunks")
                .insert(chunk)
                .execute()
            )

            return "inserted"

        except Exception as exc:

            if attempt == MAX_RETRIES:
                raise RuntimeError(
                    f"Failed to upsert chunk "
                    f"{source}:{chunk_index} "
                    f"after {MAX_RETRIES} attempts. "
                    f"Original error: {exc}"
                ) from exc

            print(
                f"[RETRY] Supabase request failed for "
                f"{source}:{chunk_index} "
                f"(attempt {attempt}/{MAX_RETRIES})"
            )

            time.sleep(RETRY_DELAY_SECONDS * attempt)

    raise RuntimeError("Unexpected ingestion state.")


# ---------------------------------------------------------
# Knowledge Base Ingestion
# ---------------------------------------------------------

def ingest_knowledge_base() -> Dict[str, int]:
    """
    Ingest the complete Markdown knowledge base.

    Pipeline:

        Markdown files
            ↓
        MarkdownHeaderTextSplitter
            ↓
        RecursiveCharacterTextSplitter
            ↓
        Knowledge chunks
            ↓
        Gemini embeddings
            ↓
        Supabase pgvector
    """

    chunks: List[Dict] = load_and_chunk_knowledge_base()

    files_processed = len(
        {chunk["source"] for chunk in chunks}
    )

    chunks_processed = len(chunks)

    chunks_inserted = 0
    chunks_updated = 0

    print(
        f"[INFO] Found {files_processed} knowledge files."
    )

    print(
        f"[INFO] Found {chunks_processed} chunks."
    )

    for index, chunk in enumerate(chunks, start=1):

        print(
            f"[INFO] Processing chunk "
            f"{index}/{chunks_processed}: "
            f"{chunk['source']} "
            f"(chunk {chunk['chunk_index']})"
        )

        # -------------------------------------------------
        # Generate Gemini embedding
        # -------------------------------------------------

        embedding: List[float] = embed_document(
            chunk["content"]
        )

        # Safety validation before touching database.
        if len(embedding) != 3072:
            raise ValueError(
                f"Invalid embedding dimension for "
                f"{chunk['source']} "
                f"chunk {chunk['chunk_index']}: "
                f"expected 3072, got {len(embedding)}"
            )

        # -------------------------------------------------
        # Prepare database row
        # -------------------------------------------------

        row = {
            "content": chunk["content"],
            "embedding": embedding,
            "source": chunk["source"],
            "category": chunk["category"],
            "section": chunk["section"],
            "chunk_index": chunk["chunk_index"],
        }

        # -------------------------------------------------
        # Insert / Update
        # -------------------------------------------------

        result = _upsert_chunk(row)

        if result == "inserted":
            chunks_inserted += 1
        else:
            chunks_updated += 1

    return {
        "files_processed": files_processed,
        "chunks_processed": chunks_processed,
        "chunks_inserted": chunks_inserted,
        "chunks_updated": chunks_updated,
    }