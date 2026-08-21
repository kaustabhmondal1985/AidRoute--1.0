"""
AidRoute Gemini Client.

Centralized Gemini API client used by AidRoute AI agents.
"""

import os
from typing import Optional

from dotenv import load_dotenv
from google import genai


# Resolve backend/.env
ENV_PATH = os.path.join(
    os.path.dirname(
        os.path.dirname(
            os.path.dirname(__file__)
        )
    ),
    ".env",
)

load_dotenv(ENV_PATH)


class GeminiClient:
    """
    Centralized Gemini text-generation client.
    """

    MODEL_NAME = "gemini-3.6-flash"

    def __init__(
        self,
        api_key: Optional[str] = None,
    ):
        self.api_key = (
            api_key
            or os.getenv("GEMINI_API_KEY")
        )

        if not self.api_key:
            raise RuntimeError(
                "GEMINI_API_KEY not found in backend/.env"
            )

        self.client = genai.Client(
            api_key=self.api_key
        )

    def generate(self, prompt: str) -> str:
        """
        Generate a text response from Gemini.
        """

        if not isinstance(prompt, str):
            raise ValueError(
                "Prompt must be a string."
            )

        prompt = prompt.strip()

        if not prompt:
            raise ValueError(
                "Prompt must not be empty."
            )

        response = self.client.models.generate_content(
            model=self.MODEL_NAME,
            contents=prompt,
        )

        if response is None:
            raise RuntimeError(
                "Gemini returned an empty response."
            )

        text = getattr(
            response,
            "text",
            None,
        )

        if not text:
            raise RuntimeError(
                "Gemini response did not contain text."
            )

        return text.strip()


if __name__ == "__main__":
    print("[INFO] Testing Gemini client...")
    print(
        f"[INFO] Model: {GeminiClient.MODEL_NAME}"
    )

    try:
        client = GeminiClient()

        response = client.generate(
            "Respond with exactly: "
            "AidRoute Gemini client works."
        )

        print("[OK] Gemini response:")
        print(response)

        print(
            "[OK] Gemini client test passed."
        )

    except Exception as exc:
        print(
            f"[ERROR] Gemini client test failed: {exc}"
        )
        raise


def generate_text(prompt: str) -> str:
    client = GeminiClient()
    return client.generate(prompt)