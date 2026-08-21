import json
from typing import Any, Dict, List, Optional

from lib.backend.app.ai.gemini_client import GeminiClient


class IntakeAgent:
    """
    Generic AI-powered legal intake agent.

    Uses Gemini to:
    - Understand the legal case
    - Understand previous questions and answers
    - Extract useful case facts
    - Identify only important missing information
    - Ask one concise follow-up question
    - Decide when intake is sufficiently complete

    This agent does not provide legal advice.
    """

    MAX_QUESTIONS = 5

    def __init__(
        self,
        gemini_client: Optional[GeminiClient] = None,
    ):
        self.gemini = gemini_client or GeminiClient()

    def _build_prompt(
        self,
        category: str,
        user_message: str,
        case_facts: List[str],
        messages: List[Dict[str, str]],
        documents: List[Dict[str, Any]],
    ) -> str:

        conversation_parts = []

        for message in messages:
            role = str(
                message.get("role", "")
            ).strip().upper()

            content = str(
                message.get("content", "")
            ).strip()

            if content:
                conversation_parts.append(
                    f"{role}: {content}"
                )

        conversation = "\n".join(
            conversation_parts
        )

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

Your role is ONLY to collect the minimum important information
needed to understand a user's legal-aid case.

You are NOT a lawyer.
You must NOT provide legal advice.
You must NOT determine legal validity.
You must NOT make legal judgments.
You must NOT tell the user what legal action they should take.

==================================================
CASE
==================================================

CATEGORY:
{category}

LATEST USER MESSAGE:
{user_message}

==================================================
FULL CONVERSATION
==================================================

{conversation if conversation else "No previous conversation."}

==================================================
KNOWN CASE FACTS
==================================================

{facts if facts else "No known case facts."}

==================================================
UPLOADED DOCUMENTS
==================================================

{documents_text if documents_text else "No uploaded documents."}

==================================================
YOUR TASK
==================================================

Analyze the ENTIRE conversation.

The user is having a natural chat with AidRoute.
Do not behave like a form.

You must understand the user's answers using conversation context.

For example:

Assistant:
"Do you have a written rent agreement?"

User:
"haan"

This means the user has a written rent agreement.

Assistant:
"Did the landlord give you a written notice?"

User:
"nahi, bas verbally bola"

This means there was no written notice and the landlord only
gave a verbal instruction.

Do NOT ask the user to repeat information that is already clear.

==================================================
QUESTION RULES
==================================================

1. NEVER use a predefined or hardcoded question list.

2. Decide dynamically what information matters for THIS case.

3. Ask ONLY ONE question at a time.

4. Ask the MOST IMPORTANT missing question first.

5. Keep questions short and natural.

6. Prefer conversational language over formal questionnaire language.

7. If the user speaks Hindi/Hinglish, respond in Hindi/Hinglish.

8. If the user speaks English, respond in English.

9. Understand:
   - yes
   - no
   - haan
   - nahi
   - haa
   - nah
   - yeah
   - nope
   - "de diya"
   - "nahi mila"
   - "verbally bola"
   - "21 august"
   - and other natural conversational answers
   using the previous question and conversation context.

10. NEVER repeat a question that has already been answered.

11. NEVER repeat a question merely because the user's answer
    was short.

12. If the user gives a direct answer such as:
    "21 august"
    understand that it is probably the answer to the previous
    date/deadline question.

13. If the user says something like:
    "nahi maine rent nahi diya"
    treat that as meaningful information about the rent/payment
    situation. Do not ask the exact same question again.

14. Combine related information when possible.

15. Do not ask unnecessary personal questions.

16. Do not ask for information that does not materially help
    understand the case.

17. Do not ask more than necessary.

18. Usually aim to complete intake within about 3-5 meaningful
    questions.

19. If enough information has already been collected to
    understand the basic situation, mark intake complete.

20. Do NOT continue questioning just to make the case more
    detailed.

==================================================
IMPORTANT INFORMATION PRIORITY
==================================================

Prioritize information such as:

- What happened
- Who is involved
- What the other party did or said
- Important dates or deadlines
- Whether there is a written notice/document
- Relevant agreement or contract
- Important payment/dispute facts
- Whether a court/official authority is involved
- Immediate safety or urgency indicators
- Other information that is genuinely important for this
  specific category

Do NOT require every item.

Only collect information that is relevant to the actual case.

==================================================
DUPLICATE QUESTION PREVENTION
==================================================

Before generating a question:

1. Look at every previous ASSISTANT message.

2. Identify questions already asked.

3. Look at the USER response immediately after each question.

4. Determine whether that question has already been answered.

5. If it has been answered, NEVER ask it again.

6. If the latest user message answers the previous question,
   move to the next most important missing information.

7. If the previous question and latest answer are unclear,
   you may ask ONE clarification question.

==================================================
LANGUAGE
==================================================

Match the user's language.

Examples:

User:
"landlord mujhe ghar se nikal raha hai"

Good:
"Kya landlord ne aapko koi written notice diya hai?"

User:
"haan agreement hai"

Good:
"Landlord ne aapko ghar khali karne ke liye koi date di hai?"

Do not unnecessarily translate the user's conversation
into formal English.

==================================================
CASE FACTS
==================================================

Extract useful facts from the current conversation.

Facts should be concise.

Examples:

"User currently lives in the rented property."

"Landlord asked the user to vacate."

"Landlord gave a verbal eviction request."

"User has a written rent agreement."

"User was told to vacate by 21 August."

"Rent payment was delayed."

Do not invent facts.

==================================================
COMPLETION RULE
==================================================

Set intake_complete = true when:

- The basic situation is understood
- The important facts for this category are known
- There is no critical missing information needed for the
  next workflow stage

Do NOT keep asking questions simply because some details
could theoretically be collected.

If the case is already sufficiently clear, STOP.

==================================================
OUTPUT
==================================================

Return ONLY valid JSON.

Use EXACTLY this structure:

{{
    "intake_complete": true or false,

    "missing_information": [
        "short description of genuinely important missing information"
    ],

    "pending_question": "ONE short natural question or null",

    "case_facts": [
        "important fact 1",
        "important fact 2"
    ]
}}

If complete:

{{
    "intake_complete": true,
    "missing_information": [],
    "pending_question": null,
    "case_facts": [
        "important fact 1",
        "important fact 2"
    ]
}}

If more information is genuinely required:

{{
    "intake_complete": false,
    "missing_information": [
        "important missing information"
    ],
    "pending_question": "ONE concise question",
    "case_facts": [
        "important fact 1",
        "important fact 2"
    ]
}}

IMPORTANT:

- Return valid JSON only.
- No markdown.
- No ```json.
- No explanations.
- No legal advice.
- No repeated questions.
- No unnecessary questions.
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

        case_facts = result.get(
            "case_facts",
            [],
        )

        if not isinstance(
            case_facts,
            list,
        ):
            case_facts = []

        case_facts = [
            str(fact).strip()
            for fact in case_facts
            if str(fact).strip()
        ]

        if intake_complete:
            missing_information = []
            pending_question = None

        return {
            "intake_complete": intake_complete,
            "missing_information": missing_information,
            "pending_question": pending_question,
            "case_facts": case_facts,
        }

    def _question_already_asked(
        self,
        question: Optional[str],
        messages: List[Dict[str, str]],
    ) -> bool:

        if not question:
            return False

        normalized_question = (
            question.strip().lower()
        )

        for message in messages:

            if message.get("role") != "assistant":
                continue

            content = (
                message.get("content", "")
                .strip()
                .lower()
            )

            if content == normalized_question:
                return True

        return False

    def assess(
        self,
        category: str,
        user_message: str,
        case_facts: Optional[List[str]] = None,
        messages: Optional[List[Dict[str, str]]] = None,
        documents: Optional[List[Dict[str, Any]]] = None,
    ) -> Dict[str, Any]:

        if not category or not category.strip():
            raise ValueError(
                "category cannot be empty."
            )

        if not user_message or not user_message.strip():
            raise ValueError(
                "user_message cannot be empty."
            )

        case_facts = list(
            case_facts or []
        )

        messages = list(
            messages or []
        )

        documents = list(
            documents or []
        )

        prompt = self._build_prompt(
            category=category.strip(),
            user_message=user_message.strip(),
            case_facts=case_facts,
            messages=messages,
            documents=documents,
        )

        response = self.gemini.generate(
            prompt
        )

        result = self._parse_response(
            response
        )

        pending_question = result.get(
            "pending_question"
        )

        # Safety check against duplicate questions.
        if self._question_already_asked(
            pending_question,
            messages,
        ):
            result["pending_question"] = None

            # Do not automatically mark complete here.
            # The next workflow turn can ask Gemini again
            # with the updated conversation.
            if result["missing_information"]:
                result["intake_complete"] = False

        return result


if __name__ == "__main__":

    print(
        "[INFO] Testing AidRoute AI Intake Agent..."
    )

    agent = IntakeAgent()

    messages = [
        {
            "role": "user",
            "content": (
                "landlord mujhe ghar se nikalne "
                "bol raha hai"
            ),
        },
        {
            "role": "assistant",
            "content": (
                "Kya landlord ne aapko koi "
                "written notice diya hai?"
            ),
        },
        {
            "role": "user",
            "content": (
                "haan 21st august likha hai"
            ),
        },
    ]

    result = agent.assess(
        category="HOUSING_EVICTION",
        user_message=(
            "haan 21st august likha hai"
        ),
        case_facts=[],
        messages=messages,
        documents=[],
    )

    print()
    print(
        "========== AI INTAKE =========="
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

    print(
        "Facts    :",
        result["case_facts"],
    )

    print()
    print(
        "[OK] AI Intake Agent test passed."
    )