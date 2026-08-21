
import json
from typing import Any, Dict, List, Optional

from lib.backend.app.ai.groq_client import GroqClient


class UrgencyAgent:
    """
    AI-powered urgency assessment agent for AidRoute.

    Uses Groq instead of Gemini.

    Responsibilities:
    - Review the complete legal intake conversation
    - Consider case category and collected facts
    - Assess urgency
    - Identify whether human review is required
    - Never provide legal advice
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

        return f"""
You are AidRoute's AI Urgency Assessment Agent.

You are NOT a lawyer.
You must NOT provide legal advice.
You must NOT determine whether any legal action is valid.
You must NOT make legal conclusions.

Your job is ONLY to assess how urgently this case should
be reviewed by a human legal-aid professional.

CASE CATEGORY:
{category}

LATEST USER MESSAGE:
{user_message}

COMPLETE CONVERSATION:
{conversation if conversation else "No conversation available."}

CASE FACTS:
{facts if facts else "No structured case facts available."}

URGENCY LEVELS:

LOW:
- No immediate deadline
- No immediate threat
- Situation can reasonably wait for normal review

MEDIUM:
- There is a meaningful deadline
- Important documents or payments are involved
- User may face consequences soon
- Situation requires relatively prompt review

HIGH:
- Immediate eviction or removal is threatened
- Very short deadline such as 1-7 days
- Court/legal notice has been received
- Essential housing or livelihood is at immediate risk
- Immediate human review would be appropriate

CRITICAL:
- Immediate physical danger
- Violence or threats of violence
- Imminent loss of life or serious physical harm
- Emergency situation requiring immediate human intervention

IMPORTANT RULES:

1. Use the complete conversation, not only the latest message.

2. Do not ask questions.

3. Do not invent facts.

4. Do not provide legal advice.

5. Do not say that the user will definitely win or lose.

6. A short eviction notice should generally be treated as HIGH urgency.

7. A normal housing dispute without an immediate deadline may be MEDIUM.

8. If there is immediate physical danger, use CRITICAL.

9. Keep the explanation short.

10. Return ONLY valid JSON.

Required JSON format:

{{
    "urgency": "LOW",
    "reason": "Short explanation",
    "human_review_required": false
}}

Allowed urgency values:

LOW
MEDIUM
HIGH
CRITICAL

human_review_required should normally be true for HIGH or CRITICAL cases.

For LOW or MEDIUM cases, use your judgment based on the
information available.

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
                f"Urgency Agent returned invalid JSON: {exc}"
            )

        if not isinstance(result, dict):
            raise ValueError(
                "Urgency Agent response must be a JSON object."
            )

        urgency = str(
            result.get(
                "urgency",
                "MEDIUM",
            )
        ).upper().strip()

        allowed_levels = {
            "LOW",
            "MEDIUM",
            "HIGH",
            "CRITICAL",
        }

        if urgency not in allowed_levels:
            urgency = "MEDIUM"

        reason = str(
            result.get(
                "reason",
                "",
            )
        ).strip()

        human_review_required = result.get(
            "human_review_required",
            urgency in {"HIGH", "CRITICAL"},
        )

        if not isinstance(
            human_review_required,
            bool,
        ):
            human_review_required = (
                urgency in {"HIGH", "CRITICAL"}
            )

        if urgency in {"HIGH", "CRITICAL"}:
            human_review_required = True

        return {
            "urgency": urgency,
            "reason": reason,
            "human_review_required": human_review_required,
        }

    def assess(
        self,
        category: str,
        user_message: str,
        case_facts: Optional[List[str]] = None,
        messages: Optional[List[Dict[str, str]]] = None,
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

        prompt = self._build_prompt(
            category=category.strip(),
            user_message=user_message.strip(),
            case_facts=case_facts,
            messages=messages,
        )

        response = self.groq.generate(
            prompt
        )

        return self._parse_response(
            response
        )


if __name__ == "__main__":

    print(
        "[INFO] Testing AidRoute Groq Urgency Agent..."
    )

    agent = UrgencyAgent()

    messages = [
        {
            "role": "user",
            "content": (
                "Landlord mujhe ghar se nikalne bol raha hai."
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
        {
            "role": "assistant",
            "content": (
                "Notice kab diya gaya?"
            ),
        },
        {
            "role": "user",
            "content": (
                "18 August ko diya tha."
            ),
        },
    ]

    result = agent.assess(
        category="HOUSING_EVICTION",
        user_message=(
            "18 August ko 3-day notice diya tha."
        ),
        case_facts=[
            "3-day eviction notice received",
            "Notice date: 18 August",
            "Rent is overdue",
        ],
        messages=messages,
    )

    print()
    print("========== GROQ URGENCY ==========")

    print(
        "Urgency :",
        result["urgency"],
    )

    print(
        "Reason  :",
        result["reason"],
    )

    print(
        "Review  :",
        result["human_review_required"],
    )

    print()
    print(
        "[OK] Groq Urgency Agent test passed."
    )

