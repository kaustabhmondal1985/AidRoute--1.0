from typing import Any, Dict, List, Optional
from typing_extensions import TypedDict


class CaseState(TypedDict, total=False):
    user_message: str
    language: Optional[str]

    messages: List[Dict[str, str]]

    category: Optional[str]
    category_confidence: Optional[float]
    category_reason: Optional[str]

    city: Optional[str]

    case_facts: List[str]
    documents: List[Dict[str, Any]]

    missing_information: List[str]
    pending_question: Optional[str]
    intake_complete: bool

    urgency: Optional[str]
    urgency_reason: Optional[str]

    rag_context: List[Dict[str, Any]]

    legal_information: Optional[str]
    legal_sources: List[Dict[str, Any]]

    lawyers: List[Dict[str, Any]]

    requires_human_review: bool
    human_review_reason: Optional[str]

    status: Optional[str]
    error: Optional[str]