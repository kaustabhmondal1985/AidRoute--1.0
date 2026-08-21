"""
AidRoute Legal Information Agent.

Uses:
- RAG retriever for trusted knowledge
- GeminiClient for response generation

The agent provides general legal information only.
It does not determine legal validity or replace a lawyer.
"""

from typing import Any, Dict, List, Optional

from lib.backend.app.ai.gemini_client import GeminiClient
from lib.backend.app.rag.retriever import retrieve_relevant_chunks


class LegalInfoAgent:
    """
    Generates grounded legal information using AidRoute's RAG knowledge base.
    """

    def __init__(
        self,
        gemini_client: Optional[GeminiClient] = None,
    ):
        self.gemini = gemini_client or GeminiClient()

    def _build_prompt(
        self,
        query: str,
        category: str,
        retrieved_chunks: List[Dict[str, Any]],
    ) -> str:

        knowledge_parts = []

        for index, chunk in enumerate(
            retrieved_chunks,
            start=1,
        ):
            knowledge_parts.append(
                f"""
Knowledge {index}
Source: {chunk.get("source", "")}
Category: {chunk.get("category", "")}
Section: {chunk.get("section", "")}

Content:
{chunk.get("content", "")}
""".strip()
            )

        knowledge = "\n\n".join(knowledge_parts)

        return f"""
You are AidRoute's Legal Information Agent.

Your role is to provide clear, general legal information
based ONLY on the supplied AidRoute knowledge.

IMPORTANT RULES:

1. Do not invent laws, sections, deadlines, procedures,
   rights, or legal facts.

2. Do not claim that a legal document or action is valid
   or invalid.

3. Do not provide a definitive legal judgment.

4. Do not present yourself as a lawyer.

5. If the supplied knowledge does not contain enough
   information to answer the question, clearly say so.

6. Keep the answer practical and easy to understand.

7. Mention relevant documents when supported by the
   supplied knowledge.

8. If the knowledge indicates possible urgency,
   advise the user to seek appropriate legal assistance
   promptly.

9. Never fabricate information.

10. Base the response strictly on the retrieved knowledge.

CASE CATEGORY:
{category}

USER QUESTION:
{query}

RETRIEVED KNOWLEDGE:
{knowledge}

Return a concise response with these sections:

1. What this issue appears to involve
2. What information/documents may be relevant
3. What the user can do next
4. Why speaking with a lawyer may help, when appropriate

Include a short disclaimer that this is general
information and not a substitute for legal advice.
""".strip()

    def _normalize_chunks(
        self,
        chunks: List[Any],
    ) -> List[Dict[str, Any]]:

        normalized = []

        for chunk in chunks:

            if hasattr(chunk, "model_dump"):
                chunk = chunk.model_dump()

            elif hasattr(chunk, "dict"):
                chunk = chunk.dict()

            elif not isinstance(chunk, dict):
                chunk = {
                    "content": str(chunk),
                }

            normalized.append(
                {
                    "content": chunk.get("content", ""),
                    "source": chunk.get("source"),
                    "category": chunk.get("category"),
                    "section": chunk.get("section"),
                    "chunk_index": chunk.get("chunk_index"),
                    "similarity": chunk.get("similarity"),
                }
            )

        return normalized

    def generate_information(
        self,
        user_message: Optional[str] = None,
        rag_context: Optional[List[Dict[str, Any]]] = None,
        query: Optional[str] = None,
        category: Optional[str] = None,
        top_k: int = 5,
    ) -> Dict[str, Any]:
        """
        Generate grounded legal information.

        Supports two usage styles:

        1. LangGraph:
            generate_information(
                user_message="...",
                rag_context=[...]
            )

        2. Direct usage:
            generate_information(
                query="...",
                category="HOUSING_EVICTION"
            )
        """

        final_query = (
            user_message
            if user_message is not None
            else query
        )

        if not final_query or not final_query.strip():
            raise ValueError(
                "user_message/query must not be empty."
            )

        final_query = final_query.strip()

        if top_k <= 0:
            raise ValueError(
                "top_k must be greater than zero."
            )

        retrieved_chunks = []

        # ---------------------------------------------------------
        # 1. Use RAG context supplied by LangGraph if available
        # ---------------------------------------------------------

        if rag_context:
            retrieved_chunks = self._normalize_chunks(
                rag_context
            )

        # ---------------------------------------------------------
        # 2. Otherwise retrieve directly from RAG
        # ---------------------------------------------------------

        if not retrieved_chunks:

            if not category or not category.strip():
                raise ValueError(
                    "category is required when rag_context is not provided."
                )

            category = category.strip()

            retrieved_chunks = retrieve_relevant_chunks(
                query=final_query,
                category=category,
                top_k=top_k,
            )

            retrieved_chunks = self._normalize_chunks(
                retrieved_chunks
            )

        # ---------------------------------------------------------
        # 3. Determine category
        # ---------------------------------------------------------

        final_category = category

        if not final_category and retrieved_chunks:
            final_category = retrieved_chunks[0].get(
                "category"
            )

        if not final_category:
            final_category = "UNKNOWN"

        final_category = str(final_category).strip()

        # ---------------------------------------------------------
        # 4. Handle no knowledge
        # ---------------------------------------------------------

        if not retrieved_chunks:

            return {
                "query": final_query,
                "category": final_category,
                "answer": (
                    "I could not find enough relevant "
                    "information in the AidRoute knowledge "
                    "base to answer this question reliably."
                ),
                "legal_information": (
                    "I could not find enough relevant "
                    "information in the AidRoute knowledge "
                    "base to answer this question reliably."
                ),
                "sources": [],
                "knowledge_chunks": 0,
            }

        # ---------------------------------------------------------
        # 5. Build grounded prompt
        # ---------------------------------------------------------

        prompt = self._build_prompt(
            query=final_query,
            category=final_category,
            retrieved_chunks=retrieved_chunks,
        )

        # ---------------------------------------------------------
        # 6. Generate Gemini response
        # ---------------------------------------------------------

        answer = self.gemini.generate(prompt)

        # ---------------------------------------------------------
        # 7. Normalize sources
        # ---------------------------------------------------------

        sources = []

        for chunk in retrieved_chunks:

            sources.append(
                {
                    "source": chunk.get("source"),
                    "category": chunk.get("category"),
                    "section": chunk.get("section"),
                    "chunk_index": chunk.get(
                        "chunk_index"
                    ),
                    "similarity": chunk.get(
                        "similarity"
                    ),
                }
            )

        # ---------------------------------------------------------
        # 8. Return unified result
        # ---------------------------------------------------------

        return {
            "query": final_query,
            "category": final_category,
            "answer": answer,
            "legal_information": answer,
            "sources": sources,
            "knowledge_chunks": len(
                retrieved_chunks
            ),
        }

    def generate(
        self,
        query: str,
        category: str,
        top_k: int = 5,
    ) -> Dict[str, Any]:
        """
        Direct/standalone interface for the Legal Info Agent.
        """

        return self.generate_information(
            query=query,
            category=category,
            top_k=top_k,
        )


if __name__ == "__main__":

    print(
        "[INFO] Testing AidRoute Legal Info Agent..."
    )

    test_query = (
        "My landlord is trying to evict me "
        "from my rented home."
    )

    test_category = "HOUSING_EVICTION"

    try:

        agent = LegalInfoAgent()

        result = agent.generate(
            query=test_query,
            category=test_category,
            top_k=5,
        )

        print(
            "\n[OK] Legal information generated."
        )

        print(
            "\n========== LEGAL INFORMATION =========="
        )

        print(
            result["answer"]
        )

        print(
            "\n========== SOURCES =========="
        )

        for index, source in enumerate(
            result["sources"],
            start=1,
        ):

            print(
                f"{index}. "
                f"{source['source']} | "
                f"{source['category']} | "
                f"Chunk {source['chunk_index']} | "
                f"Similarity {source['similarity']}"
            )

        print(
            "\n[OK] Legal Info Agent test passed."
        )

    except Exception as exc:

        print(
            f"[ERROR] Legal Info Agent test failed: {exc}"
        )

        raise