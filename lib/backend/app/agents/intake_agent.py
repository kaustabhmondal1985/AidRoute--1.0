import json
from typing import Any, Dict, List, Optional

from lib.backend.app.ai.groq_client import GroqClient


class IntakeAgent:
    """
    Generic AI-powered legal intake agent.

    The agent:
    - Understands the current legal case category
    - Reviews the complete conversation
    - Reviews facts extracted from uploaded documents
    - Identifies important missing information
    - Generates a natural follow-up question
    - Determines when enough information has been collected

    No legal advice is provided by this agent.
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
You are AidRoute's AI Legal Intake Agent.

Your task is to conduct a short, natural legal-aid intake conversation.

You are NOT a lawyer.
You must NOT provide legal advice.
You must NOT determine legal validity.
You must NOT make legal judgments.

Your only responsibility is to understand the user's situation
and determine whether enough useful information has been collected
for the next stage of the AidRoute workflow.

USER LANGUAGE: {language}

CASE CATEGORY:
{category}

LATEST USER MESSAGE:
{user_message}

COMPLETE CONVERSATION:
{conversation}

CASE FACTS:
{facts if facts else "No case facts available."}

UPLOADED DOCUMENTS:
{documents_text if documents_text else "No uploaded documents available."}

IMPORTANT RULES:

1. Analyze the COMPLETE conversation, not only the latest message.

2. Do NOT use a fixed question list.

3. Dynamically decide what information is important for THIS case.

4. Do not ask for information that the user has already provided.

5. Do not ask for information that is clearly available in documents.

6. Ask ONLY ONE question at a time.

7. Keep the number of questions LOW.

8. Ask only information that is genuinely useful for understanding
   the case and deciding the next workflow step.

9. Prefer combining closely related information into one question.

10. Do not ask unnecessary personal information.

11. Do not repeat a question that has already been answered.

12. If the latest user message answers the previous question,
    use that answer and move to the next important missing information.

13. Understand short answers such as:
    "yes", "no", "haan", "nahi", "yep", "nope", "de diya",
    "nahi hai", "21 august", etc. using the conversation context.

14. If the user provides multiple pieces of information in one message,
    extract and use all of them.

15. If enough useful information has been collected,
    mark intake as complete.

16. Do not keep asking questions just to make the intake longer.

17. Do not invent facts.

18. If a document contains relevant information, treat that information
    as already known.

19. Questions should sound natural and conversational.

20. IMPORTANT: Ask questions in the USER'S LANGUAGE ({language}).
    If the user selected Hindi, ask in Hindi/Hinglish.
    If the user selected English, ask in English.
    If the user selected Marathi, ask in Marathi.
    Do not randomly switch languages.

21. The goal is NOT to collect every possible detail.
    The goal is to collect the minimum useful information required
    to understand the case.

22. For a normal legal-aid case, prefer approximately 2-5 useful
    follow-up questions when possible. Ask more only when genuinely
    necessary.

23. If the user has already provided enough context for a meaningful
    legal-aid workflow, mark the intake complete.

Return ONLY valid JSON.

Required format:

{{
    "intake_complete": true,
    "missing_information": [],
    "pending_question": null
}}

OR:

{{
    "intake_complete": false,
    "missing_information": [
        "short description of missing information"
    ],
    "pending_question": "ONE natural follow-up question in the user's language ({language})"
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
                f"Intake Agent returned invalid JSON: {exc}"
            )

        if not isinstance(result, dict):
            raise ValueError(
                "Intake Agent response must be a JSON object."
            )

        intake_complete = bool(
            result.get(
                "intake_complete",
                False,
            )
        )

        missing_information = result.get(
            "missing_information",
            [],
        )

        if not isinstance(
            missing_information,
            list,
        ):
            missing_information = []

        missing_information = [
            str(item).strip()
            for item in missing_information
            if str(item).strip()
        ]

        pending_question = result.get(
            "pending_question"
        )

        if pending_question is not None:
            pending_question = str(
                pending_question
            ).strip()

            if not pending_question:
                pending_question = None

        if intake_complete:
            missing_information = []
            pending_question = None

        return {
            "intake_complete": intake_complete,
            "missing_information": missing_information,
            "pending_question": pending_question,
        }

    def assess(
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
        "[INFO] Testing AidRoute Groq Intake Agent..."
    )

    agent = IntakeAgent()

    messages = [
        {
            "role": "user",
            "content": (
                "Landlord mujhe ghar se nikalne bol raha hai. "
                "Rent late hua tha."
            ),
        }
    ]

    result = agent.assess(
        category="HOUSING_EVICTION",
        user_message=(
            "Landlord mujhe ghar se nikalne bol raha hai. "
            "Rent late hua tha."
        ),
        case_facts=[],
        messages=messages,
        documents=[],
    )

    print()
    print(
        "========== GROQ INTAKE =========="
    )

    print(
        "Complete :",
        result["intake_complete"],
    )

    print(
        "Missing  :",
        result["missing_information"],
    )

    print(
        "Question :",
        result["pending_question"],
    )

    print()
    print(
        "[OK] Groq Intake Agent test passed."
    )