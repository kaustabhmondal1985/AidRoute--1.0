import os
from typing import List, Dict, Optional

from dotenv import load_dotenv
from supabase import create_client, Client

from .embeddings import embed_query


# ---------------------------------------------------------
# Environment
# ---------------------------------------------------------

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_DIR = os.path.abspath(
    os.path.join(CURRENT_DIR, "../..")
)

ENV_PATH = os.path.join(BACKEND_DIR, ".env")
load_dotenv(ENV_PATH)


SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY")

supabase: Optional[Client] = None

if SUPABASE_URL and SUPABASE_SERVICE_KEY:
    try:
        supabase = create_client(
            SUPABASE_URL,
            SUPABASE_SERVICE_KEY
        )
    except Exception as e:
        print(f"[WARNING] Failed to initialize Supabase client: {e}")
        supabase = None
else:
    print("[WARNING] Supabase credentials not found. RAG retrieval will be disabled.")


# ---------------------------------------------------------
# RAG Configuration
# ---------------------------------------------------------

EMBEDDING_DIMENSION = 3072
DEFAULT_TOP_K = 5
DEFAULT_MATCH_THRESHOLD = 0.30


# ---------------------------------------------------------
# Retriever
# ---------------------------------------------------------

def retrieve_relevant_chunks(
    query: str,
    top_k: int = DEFAULT_TOP_K,
    match_threshold: float = DEFAULT_MATCH_THRESHOLD,
    category: Optional[str] = None,
) -> List[Dict]:

    if not query or not query.strip():
        raise ValueError("Query cannot be empty.")

    if top_k <= 0:
        raise ValueError(
            "top_k must be greater than zero."
        )

    if not 0.0 <= match_threshold <= 1.0:
        raise ValueError(
            "match_threshold must be between 0.0 and 1.0."
        )

    # Return empty results if Supabase is not configured
    if not supabase:
        print("[WARNING] Supabase not configured, returning empty RAG results")
        return []

    print("[INFO] Generating query embedding...")

    query_embedding = embed_query(query)

    print(
        f"[INFO] Query embedding dimension: "
        f"{len(query_embedding)}"
    )

    if len(query_embedding) != EMBEDDING_DIMENSION:
        raise ValueError(
            f"Query embedding must contain "
            f"{EMBEDDING_DIMENSION} dimensions, "
            f"got {len(query_embedding)}."
        )

    params = {
        "query_embedding": query_embedding,
        "match_threshold": match_threshold,
        "match_count": top_k,
    }

    print("[INFO] Searching Supabase pgvector...")

    response = (
        supabase
        .rpc(
            "match_knowledge_chunks",
            params
        )
        .execute()
    )

    results = response.data or []

    if category:
        results = [
            result
            for result in results
            if result.get("category") == category
        ]

    normalized_results = []

    for result in results:

        normalized_results.append(
            {
                "id": result.get("id"),
                "content": result.get(
                    "content",
                    ""
                ),
                "source": result.get(
                    "source",
                    ""
                ),
                "category": result.get(
                    "category",
                    ""
                ),
                "section": result.get(
                    "section",
                    ""
                ),
                "chunk_index": result.get(
                    "chunk_index",
                    0
                ),
                "similarity": float(
                    result.get(
                        "similarity",
                        0.0
                    )
                ),
            }
        )

    return normalized_results


# ---------------------------------------------------------
# Agent helper
# ---------------------------------------------------------

def retrieve_for_agent(
    query: str,
    top_k: int = DEFAULT_TOP_K,
    match_threshold: float = DEFAULT_MATCH_THRESHOLD,
) -> List[Dict]:

    return retrieve_relevant_chunks(
        query=query,
        top_k=top_k,
        match_threshold=match_threshold,
    )


# ---------------------------------------------------------
# Test
# ---------------------------------------------------------

if __name__ == "__main__":

    print(
        "[INFO] Testing AidRoute RAG retriever..."
    )

    test_query = (
        "What should I do if my landlord "
        "is trying to evict me?"
    )

    print(
        f"[INFO] Query: {test_query}"
    )

    try:

        results = retrieve_relevant_chunks(
            query=test_query,
            top_k=5,
            match_threshold=0.30,
        )

        print()
        print(
            f"[OK] Retrieved {len(results)} chunks."
        )
        print()

        for index, result in enumerate(
            results,
            start=1
        ):

            print(
                f"--- Result {index} ---"
            )

            print(
                f"Similarity : "
                f"{result['similarity']:.4f}"
            )

            print(
                f"Source     : "
                f"{result['source']}"
            )

            print(
                f"Category   : "
                f"{result['category']}"
            )

            print(
                f"Section    : "
                f"{result['section']}"
            )

            print(
                f"Chunk      : "
                f"{result['chunk_index']}"
            )

            content = result["content"]

            print(
                "Content    : "
                + content[:300]
                .replace("\n", " ")
            )

            print()

        print(
            "[OK] RAG retrieval test "
            "completed successfully."
        )

    except Exception as error:

        print(
            f"[ERROR] RAG retrieval test failed: "
            f"{error}"
        )

        raise