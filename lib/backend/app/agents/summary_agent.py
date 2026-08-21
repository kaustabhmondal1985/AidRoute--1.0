
import json
import re
from typing import Any, Dict, List, Optional

from lib.backend.app.ai.groq_client import GroqClient


class SummaryAgent:
    """
    AI-powered case summary agent for AidRoute.

    Uses the existing Groq integration.

    Responsibilities:
    - Generate a concise factual case summary
    - Use conversation history, category, facts, documents
    - Never provide legal advice
    - Never invent facts or dates
    - Generate summary in user's preferred language
    """

    def __init__(
        self,
        groq_client: Optional[GroqClient] = None,
    ):
        self.groq = groq_client or GroqClient()

    def _build_prompt(
        self,
        category: str,
        user_message: str,
        case_facts: List[str],
        messages: List[Dict[str, str]],
        documents: List[Dict[str, Any]],
        language: str = "en",
    ) -> str:

        conversation_parts = []

        for message in messages:
            role = message.get("role", "")
            content = message.get("content", "").strip()

            if content:
                conversation_parts.append(
                    f"{role.upper()}: {content}"
                )

        conversation = "\n".join(conversation_parts)

        facts = "\n".join(
            f"- {fact}"
            for fact in case_facts
            if fact
        )

        document_parts = []

        for document in documents:
            if not isinstance(document, dict):
                continue

            name = document.get(
                "filename",
                document.get(
                    "name",
                    "Uploaded document",
                ),
            )

            content = document.get(
                "content",
                document.get(
                    "text",
                    document.get(
                        "extracted_text",
                        "",
                    ),
                ),
            )

            if content:
                document_parts.append(
                    f"Document: {name}\n"
                    f"Content:\n{content}"
                )

        documents_text = "\n\n".join(
            document_parts
        )

        return f"""
You are AidRoute's AI Case Summary Agent.

You are NOT a lawyer.
You must NOT provide legal advice.
You must NOT determine whether any legal action is valid.
You must NOT make legal conclusions.

Your job is ONLY to create a concise, factual summary of the legal case
for a human legal-aid professional to review.

USER LANGUAGE: {language}

CASE CATEGORY:
{category}

LATEST USER MESSAGE:
{user_message}

COMPLETE CONVERSATION:
{conversation if conversation else "No conversation available."}

CASE FACTS:
{facts if facts else "No structured case facts available."}

UPLOADED DOCUMENTS:
{documents_text if documents_text else "No uploaded documents available."}

IMPORTANT RULES:

1. Use ONLY facts provided by the user in the conversation and case facts.

2. Use document information ONLY if a real document was uploaded and processed.
   If no documents were uploaded, do NOT assume a document exists.
   Do NOT invent document content.

3. Never invent facts.
   Never invent dates.
   Never assume information that was not provided.

4. Never provide legal advice.
   Never make legal conclusions.
   Never say whether the user will win or lose.

5. Keep the summary concise, approximately 1-3 sentences.

6. Make it useful for a lawyer reviewing the case quickly.

7. Generate the summary in the USER'S LANGUAGE ({language}).
   If the user selected Hindi, write in Hindi.
   If the user selected English, write in English.
   If the user selected Marathi, write in Marathi.
   Do NOT change language based on the latest chat message.
   The initially selected language is the source of truth.

8. Return ONLY valid JSON.

Required JSON format:

{{
    "summary": "Concise factual case summary in {language}"
}}

Do not include markdown.
Do not include explanations outside JSON.
""".strip()

    def _parse_response(
        self,
        response: str,
    ) -> Dict[str, Any]:

        response = response.strip()

        if response.startswith("```"):
            response = response.replace(
                "```json",
                "",
            )
            response = response.replace(
                "```",
                "",
            )
            response = response.strip()

        try:
            result = json.loads(response)

        except json.JSONDecodeError as exc:
            raise ValueError(
                f"Summary Agent returned invalid JSON: {exc}"
            )

        if not isinstance(result, dict):
            raise ValueError(
                "Summary Agent response must be a JSON object."
            )

        summary = str(
            result.get(
                "summary",
                "",
            )
        ).strip()

        if not summary:
            raise ValueError(
                "Summary Agent returned an empty summary."
            )

        return {
            "summary": summary,
        }

    def generate(
        self,
        category: str,
        user_message: str,
        case_facts: Optional[List[str]] = None,
        messages: Optional[List[Dict[str, str]]] = None,
        documents: Optional[List[Dict[str, Any]]] = None,
        language: str = "en",
    ) -> Dict[str, Any]:

        if not category or not category.strip():
            raise ValueError(
                "category cannot be empty."
            )

        if not user_message or not user_message.strip():
            raise ValueError(
                "user_message cannot be empty."
            )

        case_facts = case_facts or []
        messages = messages or []
        documents = documents or []

        prompt = self._build_prompt(
            category=category.strip(),
            user_message=user_message.strip(),
            case_facts=case_facts,
            messages=messages,
            documents=documents,
            language=language,
        )

        response = self.groq.generate(
            prompt
        )

        return self._parse_response(
            response
        )


if __name__ == "__main__":

    print(
        "[INFO] Testing AidRoute Groq Summary Agent..."
    )

    agent = SummaryAgent()

    messages = [
        {
            "role": "user",
            "content": (
                "Landlord mujhe ghar se nikalne bol raha hai. "
                "Rent late hua tha."
            ),
        },
        {
            "role": "assistant",
            "content": (
                "Kya aapko written notice mila hai?"
            ),
        },
        {
            "role": "user",
            "content": (
                "Haan, 3-day notice mila hai."
            ),
        },
    ]

    result = agent.generate(
        category="HOUSING_EVICTION",
        user_message=(
            "Haan, 3-day notice mila hai."
        ),
        case_facts=[
            "3-day eviction notice received",
            "Rent is overdue",
        ],
        messages=messages,
        documents=[],
        language="hi",
    )

    print()
    print("========== GROQ SUMMARY ==========")

    print(
        "Summary :",
        result["summary"],
    )

    print()
    print(
        "[OK] Groq Summary Agent test passed."
    )
