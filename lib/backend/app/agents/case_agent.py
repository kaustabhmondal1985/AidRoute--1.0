
import json
import re
from typing import Dict, Optional

from lib.backend.app.ai.groq_client import GroqClient


ALLOWED_CATEGORIES = {
    "HOUSING_EVICTION",
    "FAMILY",
    "CRIMINAL",
    "CONSUMER",
    "EMPLOYMENT",
}


class CaseAgent:
    """Classifies a user's legal-aid case into a supported category."""

    def __init__(
        self,
        groq_client: Optional[GroqClient] = None,
    ):
        self.groq = groq_client or GroqClient()

    def classify(
        self,
        user_message: str,
    ) -> Dict:

        if not user_message or not user_message.strip():
            raise ValueError(
                "user_message cannot be empty."
            )

        prompt = f"""
You are AidRoute's case classification agent.

Classify the user's legal-aid problem into exactly ONE of these categories:

- HOUSING_EVICTION
- FAMILY
- CRIMINAL
- CONSUMER
- EMPLOYMENT

Rules:

1. Return only valid JSON.
2. Do not provide legal advice.
3. Do not make legal conclusions.
4. Choose the category that best matches the user's main problem.
5. Provide a confidence score between 0 and 1.
6. Give a short reason for the classification.
7. Do not include markdown or code fences.

Expected JSON format:

{{
    "category": "HOUSING_EVICTION",
    "confidence": 0.95,
    "reason": "The user describes a dispute involving a landlord and possible eviction."
}}

User message:

{user_message}
""".strip()

        response = self.groq.generate(
            prompt
        )

        if not response:
            raise RuntimeError(
                "Case classification returned an empty response."
            )

        parsed = self._parse_response(
            response
        )

        category = str(
            parsed.get(
                "category",
                "",
            )
        ).strip().upper()

        if category not in ALLOWED_CATEGORIES:
            raise ValueError(
                f"Invalid category returned by CaseAgent: {category}"
            )

        confidence = parsed.get(
            "confidence",
            0.0,
        )

        try:
            confidence = float(confidence)

        except (
            TypeError,
            ValueError,
        ):
            confidence = 0.0

        confidence = max(
            0.0,
            min(
                1.0,
                confidence,
            ),
        )

        reason = str(
            parsed.get(
                "reason",
                "",
            )
        ).strip()

        return {
            "category": category,
            "confidence": confidence,
            "reason": reason,
        }

    @staticmethod
    def _parse_response(
        response: str,
    ) -> Dict:

        response = response.strip()

        response = re.sub(
            r"^```json\s*",
            "",
            response,
            flags=re.IGNORECASE,
        )

        response = re.sub(
            r"^```\s*",
            "",
            response,
        )

        response = re.sub(
            r"\s*```$",
            "",
            response,
        )

        try:
            parsed = json.loads(
                response
            )

        except json.JSONDecodeError:

            match = re.search(
                r"\{.*\}",
                response,
                re.DOTALL,
            )

            if not match:
                raise ValueError(
                    "CaseAgent returned invalid JSON."
                )

            try:
                parsed = json.loads(
                    match.group(0)
                )

            except json.JSONDecodeError as exc:
                raise ValueError(
                    "CaseAgent returned invalid JSON."
                ) from exc

        if not isinstance(
            parsed,
            dict,
        ):
            raise ValueError(
                "CaseAgent response must be a JSON object."
            )

        return parsed


if __name__ == "__main__":

    print(
        "[INFO] Testing AidRoute Groq Case Agent..."
    )
    print()

    agent = CaseAgent()

    test_message = (
        "My landlord is threatening to remove me "
        "from my rented home."
    )

    print("[INFO] User message:")
    print(test_message)
    print()

    result = agent.classify(
        test_message
    )

    print(
        "[OK] Case classification completed."
    )
    print()

    print(
        "========== CLASSIFICATION =========="
    )

    print(
        "Category   :",
        result["category"],
    )

    print(
        "Confidence :",
        result["confidence"],
    )

    print(
        "Reason     :",
        result["reason"],
    )

    print()

    print(
        "[OK] Case Agent test passed."
    )

