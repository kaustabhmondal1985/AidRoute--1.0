"""
AidRoute Gemini Embedding Wrapper

Model:
    gemini-embedding-001

Dimension:
    3072
"""

import os
from typing import List
from unittest import mock

from dotenv import load_dotenv
import google.generativeai as genai


# Load backend/.env
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_DIR = os.path.abspath(
    os.path.join(CURRENT_DIR, "../..")
)
ENV_PATH = os.path.join(BACKEND_DIR, ".env")

load_dotenv(ENV_PATH)


EMBEDDING_MODEL = "models/gemini-embedding-001"
EMBEDDING_DIMENSION = 3072


def _configure_gemini() -> None:
    api_key = os.getenv("GEMINI_API_KEY")

    if not api_key:
        raise RuntimeError(
            "GEMINI_API_KEY not found in backend/.env. "
            "RAG embeddings require Gemini API key."
        )

    genai.configure(
        api_key=api_key,
        transport="rest",
    )


def _embed(
    text: str,
    task_type: str,
) -> List[float]:

    if not text or not text.strip():
        raise ValueError(
            "Text cannot be empty."
        )

    _configure_gemini()

    response = genai.embed_content(
        model=EMBEDDING_MODEL,
        content=text,
        task_type=task_type,
    )

    if isinstance(response, dict):
        embedding = response.get("embedding")
    else:
        embedding = getattr(
            response,
            "embedding",
            None,
        )

    if embedding is None:
        raise RuntimeError(
            "Gemini response does not contain an embedding."
        )

    embedding = list(embedding)

    if len(embedding) != EMBEDDING_DIMENSION:
        raise ValueError(
            f"Expected {EMBEDDING_DIMENSION} dimensions, "
            f"got {len(embedding)}."
        )

    return [float(x) for x in embedding]


def embed_document(
    text: str,
) -> List[float]:

    return _embed(
        text,
        "retrieval_document",
    )


def embed_query(
    text: str,
) -> List[float]:

    return _embed(
        text,
        "retrieval_query",
    )


if __name__ == "__main__":

    sample = (
        "A tenant may have legal protections "
        "when facing eviction."
    )

    mock_response = {
        "embedding": [0.0] * EMBEDDING_DIMENSION
    }

    # Mock only the Gemini API call.
    # The real environment/API is NOT required for this test.
    with mock.patch.object(
        genai,
        "embed_content",
        return_value=mock_response,
    ):

        document_vector = embed_document(sample)
        query_vector = embed_query(sample)

    assert len(document_vector) == 3072
    assert len(query_vector) == 3072

    print(
        "[OK] Gemini embedding wrapper mock test passed."
    )

    print(
        f"[OK] Document embedding dimension: "
        f"{len(document_vector)}"
    )

    print(
        f"[OK] Query embedding dimension: "
        f"{len(query_vector)}"
    )