from langgraph.graph import END, START, StateGraph

from lib.backend.app.graph.state import CaseState
from lib.backend.app.graph.nodes import (
    classify_case_node,
    intake_node,
    urgency_node,
    rag_node,
    legal_info_node,
    lawyer_matching_node,
    human_review_node,
    finalize_case_node,
)


def start_router(state: CaseState):
    category = state.get("category")

    if category:
        return "intake"

    return "classify"


def intake_router(state: CaseState):
    if state.get("intake_complete"):
        return "continue"

    return "ask"


def build_workflow():
    graph = StateGraph(CaseState)

    graph.add_node(
        "classify_case",
        classify_case_node,
    )

    graph.add_node(
        "intake",
        intake_node,
    )

    graph.add_node(
        "urgency",
        urgency_node,
    )

    graph.add_node(
        "rag",
        rag_node,
    )

    graph.add_node(
        "legal_info",
        legal_info_node,
    )

    graph.add_node(
        "lawyer_matching",
        lawyer_matching_node,
    )

    graph.add_node(
        "human_review",
        human_review_node,
    )

    graph.add_node(
        "finalize",
        finalize_case_node,
    )

    graph.add_conditional_edges(
        START,
        start_router,
        {
            "classify": "classify_case",
            "intake": "intake",
        },
    )

    graph.add_edge(
        "classify_case",
        "intake",
    )

    graph.add_conditional_edges(
        "intake",
        intake_router,
        {
            "ask": END,
            "continue": "urgency",
        },
    )

    graph.add_edge(
        "urgency",
        "rag",
    )

    graph.add_edge(
        "rag",
        "legal_info",
    )

    graph.add_edge(
        "legal_info",
        "lawyer_matching",
    )

    graph.add_edge(
        "lawyer_matching",
        "human_review",
    )

    graph.add_edge(
        "human_review",
        "finalize",
    )

    graph.add_edge(
        "finalize",
        END,
    )

    return graph.compile()


workflow = build_workflow()