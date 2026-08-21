
from typing import Any, Dict, List

from lib.backend.app.agents.case_agent import CaseAgent
from lib.backend.app.agents.intake_agent import IntakeAgent
from lib.backend.app.agents.urgency_agent import UrgencyAgent


case_agent = CaseAgent()
intake_agent = IntakeAgent()
urgency_agent = UrgencyAgent()


def _get_user_message(state: Dict[str, Any]) -> str:
    user_message = state.get("user_message", "")

    if user_message and user_message.strip():
        return user_message.strip()

    messages = state.get("messages", [])

    for message in reversed(messages):
        if isinstance(message, dict):
            if message.get("role") == "user":
                content = message.get("content", "")

                if content and content.strip():
                    return content.strip()

    return ""


def _get_messages(state: Dict[str, Any]) -> List[Dict[str, str]]:
    messages = state.get("messages", [])

    if not isinstance(messages, list):
        return []

    return messages


def _get_case_facts(state: Dict[str, Any]) -> List[str]:
    case_facts = state.get("case_facts", [])

    if not isinstance(case_facts, list):
        return []

    return case_facts


def _get_documents(state: Dict[str, Any]) -> List[Dict[str, Any]]:
    documents = state.get("documents", [])

    if not isinstance(documents, list):
        return []

    return documents


def classify_case_node(state):
    user_message = _get_user_message(state)

    if not user_message:
        raise ValueError(
            "Cannot classify case because user_message is empty."
        )

    result = case_agent.classify(
        user_message=user_message,
    )

    return {
        "category": result["category"],
        "category_confidence": result["confidence"],
        "category_reason": result["reason"],
    }


def intake_node(state):
    category = state.get("category", "")
    user_message = _get_user_message(state)

    case_facts = _get_case_facts(state)
    messages = _get_messages(state)
    documents = _get_documents(state)

    if not category:
        raise ValueError(
            "Cannot run intake because category is missing."
        )

    if not user_message:
        raise ValueError(
            "Cannot run intake because user_message is empty."
        )

    result = intake_agent.assess(
        category=category,
        user_message=user_message,
        case_facts=case_facts,
        messages=messages,
        documents=documents,
    )

    return {
        "intake_complete": result["intake_complete"],
        "missing_information": result["missing_information"],
        "pending_question": result["pending_question"],
    }


def urgency_node(state):
    category = state.get("category", "")
    user_message = _get_user_message(state)

    case_facts = _get_case_facts(state)
    messages = _get_messages(state)

    if not category:
        raise ValueError(
            "Cannot assess urgency because category is missing."
        )

    if not user_message:
        raise ValueError(
            "Cannot assess urgency because user_message is empty."
        )

    result = urgency_agent.assess(
        category=category,
        user_message=user_message,
        case_facts=case_facts,
        messages=messages,
    )

    return {
        "urgency": result["urgency"],
        "urgency_reason": result["reason"],
        "human_review_required": result[
            "human_review_required"
        ],
    }


def rag_node(state):
    """
    RAG stage.

    This node currently preserves the workflow contract.
    Actual Supabase/vector-search integration can be connected
    here without changing the workflow structure.
    """

    category = state.get("category", "")
    user_message = _get_user_message(state)

    return {
        "rag_context": [],
        "rag_query": user_message,
        "rag_category": category,
    }


def legal_info_node(state):
    """
    Legal information preparation stage.

    This node does not provide legal advice.
    It only prepares structured information for the next stage.
    """

    category = state.get("category", "")
    urgency = state.get("urgency", "")
    rag_context = state.get("rag_context", [])

    return {
        "legal_info": {
            "category": category,
            "urgency": urgency,
            "sources": rag_context,
            "disclaimer": (
                "Information is for legal-aid intake purposes "
                "and is not legal advice."
            ),
        }
    }


def lawyer_matching_node(state):
    """
    Lawyer matching preparation stage.

    Actual lawyer database matching can be connected later.
    """

    category = state.get("category", "")
    urgency = state.get("urgency", "")

    return {
        "lawyer_matches": [],
        "matching_status": "pending",
        "matching_category": category,
        "matching_urgency": urgency,
    }


def human_review_node(state):
    """
    Determines whether the case should be reviewed by a human.
    """

    human_review_required = state.get(
        "human_review_required",
        False,
    )

    urgency = state.get(
        "urgency",
        "",
    )

    if urgency == "HIGH":
        human_review_required = True

    return {
        "human_review_required": human_review_required,
        "review_status": (
            "required"
            if human_review_required
            else "not_required"
        ),
    }


def finalize_case_node(state):
    """
    Final workflow stage.

    Creates a clean final case status without providing
    legal advice.
    """

    human_review_required = state.get(
        "human_review_required",
        False,
    )

    urgency = state.get(
        "urgency",
        "MEDIUM",
    )

    if human_review_required:
        status = "human_review_required"
    else:
        status = "completed"

    return {
        "case_status": status,
        "finalized": True,
        "final_summary": {
            "category": state.get(
                "category",
                "UNKNOWN",
            ),
            "urgency": urgency,
            "human_review_required": human_review_required,
            "status": status,
        },
    }

