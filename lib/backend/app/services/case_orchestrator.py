from typing import Any, Dict, List, Optional

from lib.backend.app.agents.case_agent import CaseAgent
from lib.backend.app.agents.urgency_agent import UrgencyAgent
from lib.backend.app.agents.summary_agent import SummaryAgent
from lib.backend.app.lawyers.matcher import match_lawyers
from lib.backend.app.rag.retriever import retrieve_relevant_chunks


class CaseOrchestrator:
    """
    Coordinates the AidRoute legal case flow.

    Flow:
        User problem
            -> Case Agent
            -> category detection
            -> RAG retrieval
            -> lawyer matching
    """

    def __init__(self):
        self.case_agent = CaseAgent()
        self.urgency_agent = UrgencyAgent()
        self.summary_agent = SummaryAgent()

    def analyze_case(
        self,
        user_message: str,
        city: Optional[str] = None,
        max_lawyers: int = 5,
        max_chunks: int = 5,
        language: Optional[str] = "en",
    ) -> Dict[str, Any]:

        if not user_message or not user_message.strip():
            raise ValueError("user_message cannot be empty.")

        if max_lawyers < 1 or max_lawyers > 20:
            raise ValueError(
                "max_lawyers must be between 1 and 20."
            )

        if max_chunks < 1 or max_chunks > 20:
            raise ValueError(
                "max_chunks must be between 1 and 20."
            )

        # ---------------------------------------------------------
        # 1. Automatically classify the case
        # ---------------------------------------------------------

        classification = self.case_agent.classify(
            user_message=user_message,
        )

        category = classification["category"]
        category_confidence = classification["confidence"]
        category_reason = classification["reason"]

        # ---------------------------------------------------------
        # 2. Retrieve relevant legal knowledge
        # ---------------------------------------------------------

        try:
            rag_results = retrieve_relevant_chunks(
                query=user_message,
                top_k=max_chunks,
            )
        except Exception as e:
            print(f"[WARNING] RAG retrieval failed: {e}. Proceeding without RAG.")
            rag_results = []

        # ---------------------------------------------------------
        # 3. Assess urgency
        # ---------------------------------------------------------

        urgency_assessment = self.urgency_agent.assess(
            category=category,
            user_message=user_message,
            case_facts=[],
            messages=[],
        )

        # ---------------------------------------------------------
        # 4. Generate case summary
        # ---------------------------------------------------------

        try:
            summary_result = self.summary_agent.generate(
                category=category,
                user_message=user_message,
                case_facts=[],
                messages=[],
                documents=[],
                language=language or "en",
            )
            case_summary = summary_result.get("summary", "")
        except Exception as e:
            print(f"[WARNING] Summary generation failed: {e}. Using fallback.")
            case_summary = ""

        # ---------------------------------------------------------
        # 5. Match lawyers
        # ---------------------------------------------------------

        lawyer_results = match_lawyers(
            category=category,
            city=city,
            limit=max_lawyers,
        )

        # ---------------------------------------------------------
        # 6. Normalize RAG results
        # ---------------------------------------------------------

        knowledge: List[Dict[str, Any]] = []

        for item in rag_results:

            if hasattr(item, "model_dump"):
                item = item.model_dump()

            elif hasattr(item, "dict"):
                item = item.dict()

            elif not isinstance(item, dict):
                item = {
                    "content": str(item),
                }

            knowledge.append(
                {
                    "content": item.get("content", ""),
                    "source": item.get("source"),
                    "category": item.get("category"),
                    "section": item.get("section"),
                    "chunk_index": item.get("chunk_index"),
                    "similarity": item.get("similarity"),
                }
            )

        # ---------------------------------------------------------
        # 7. Normalize lawyer results
        # ---------------------------------------------------------

        lawyers: List[Dict[str, Any]] = []

        for lawyer in lawyer_results:

            if hasattr(lawyer, "model_dump"):
                lawyer = lawyer.model_dump()

            elif hasattr(lawyer, "dict"):
                lawyer = lawyer.dict()

            elif not isinstance(lawyer, dict):
                lawyer = {
                    "id": getattr(lawyer, "id", None),
                    "name": getattr(lawyer, "name", None),
                    "email": getattr(lawyer, "email", None),
                    "phone": getattr(lawyer, "phone", None),
                    "category": getattr(
                        lawyer,
                        "category",
                        None,
                    ),
                    "specializations": getattr(
                        lawyer,
                        "specializations",
                        [],
                    ),
                    "city": getattr(
                        lawyer,
                        "city",
                        None,
                    ),
                    "state": getattr(
                        lawyer,
                        "state",
                        None,
                    ),
                    "experience_years": getattr(
                        lawyer,
                        "experience_years",
                        0,
                    ),
                    "available": getattr(
                        lawyer,
                        "available",
                        True,
                    ),
                }

            lawyers.append(lawyer)

        # ---------------------------------------------------------
        # 8. Return unified case analysis
        # ---------------------------------------------------------

        return {
            "user_message": user_message,
            "category": category,
            "category_confidence": category_confidence,
            "category_reason": category_reason,
            "city": city,
            "knowledge": knowledge,
            "knowledge_count": len(knowledge),
            "lawyers": lawyers,
            "lawyer_count": len(lawyers),
            "urgency": urgency_assessment.get("urgency", "MEDIUM"),
            "urgency_reason": urgency_assessment.get("reason", ""),
            "human_review_required": urgency_assessment.get("human_review_required", False),
            "case_summary": case_summary,
        }


def analyze_case(
    user_message: str,
    city: Optional[str] = None,
    max_lawyers: int = 5,
    max_chunks: int = 5,
    language: Optional[str] = "en",
) -> Dict[str, Any]:

    orchestrator = CaseOrchestrator()

    return orchestrator.analyze_case(
        user_message=user_message,
        city=city,
        max_lawyers=max_lawyers,
        max_chunks=max_chunks,
        language=language,
    )


if __name__ == "__main__":

    print("[INFO] Testing AidRoute case orchestrator...")
    print()

    user_message = (
        "My landlord is trying to evict me "
        "from my rented home."
    )

    city = "Mumbai"

    print("[INFO] User message:")
    print(user_message)
    print()

    print("[INFO] City:", city)
    print()

    result = analyze_case(
        user_message=user_message,
        city=city,
        max_lawyers=5,
        max_chunks=5,
    )

    print("[OK] Case orchestration completed.")
    print()

    print("========== CLASSIFICATION ==========")
    print("Category   :", result["category"])
    print(
        "Confidence :",
        result["category_confidence"],
    )
    print("Reason     :", result["category_reason"])
    print()

    print("========== RAG ==========")
    print(
        "Knowledge chunks:",
        result["knowledge_count"],
    )
    print()

    print("========== LAWYERS ==========")
    print(
        "Lawyers found:",
        result["lawyer_count"],
    )

    for index, lawyer in enumerate(
        result["lawyers"],
        start=1,
    ):
        print()
        print(f"--- Lawyer {index} ---")
        print("Name       :", lawyer.get("name"))
        print("City       :", lawyer.get("city"))
        print(
            "Category   :",
            lawyer.get("category"),
        )
        print(
            "Experience :",
            lawyer.get("experience_years"),
            "years",
        )
        print(
            "Available  :",
            lawyer.get("available"),
        )

    print()
    print("[OK] Case Orchestrator test passed.")