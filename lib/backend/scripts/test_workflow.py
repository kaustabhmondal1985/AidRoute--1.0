from lib.backend.app.graph.workflow import workflow


def main():
    print()
    print("=" * 50)
    print("        AidRoute Legal Intake Chat")
    print("=" * 50)
    print()
    print("Type 'exit' anytime to stop.")
    print()

    state = {
        "user_message": "",
        "language": "auto",
        "messages": [],
        "category": None,
        "category_confidence": None,
        "category_reason": None,
        "city": None,
        "case_facts": [],
        "documents": [],
        "missing_information": [],
        "pending_question": None,
        "intake_complete": False,
        "urgency": None,
        "urgency_reason": None,
        "rag_context": [],
        "legal_information": None,
        "legal_sources": [],
        "lawyers": [],
        "human_review_required": False,
        "human_review_reason": None,
        "status": None,
        "error": None,
    }

    while True:

        user_input = input("You: ").strip()

        if user_input.lower() == "exit":
            print()
            print("AidRoute: Goodbye.")
            break

        if not user_input:
            continue

        state["user_message"] = user_input

        # Add user message to conversation history
        state.setdefault("messages", []).append(
            {
                "role": "user",
                "content": user_input,
            }
        )

        try:
            result = workflow.invoke(state)

            state.update(result)

        except Exception as exc:
            print()
            print("AidRoute: Sorry, something went wrong.")
            print(f"[ERROR] {exc}")
            print()
            continue

        # --------------------------------------------------
        # INTAKE QUESTION
        # --------------------------------------------------

        pending_question = result.get(
            "pending_question"
        )

        if pending_question:
            print()
            print(
                "AidRoute:",
                pending_question,
            )
            print()

            # Store assistant question in conversation
            state.setdefault("messages", []).append(
                {
                    "role": "assistant",
                    "content": pending_question,
                }
            )

            continue

        # --------------------------------------------------
        # ASSISTANT MESSAGE FROM STATE
        # --------------------------------------------------

        assistant_messages = [
            message
            for message in result.get(
                "messages",
                []
            )
            if isinstance(message, dict)
            and message.get("role") == "assistant"
        ]

        if assistant_messages:
            print()
            print(
                "AidRoute:",
                assistant_messages[-1].get(
                    "content",
                    ""
                ),
            )
            print()

        # --------------------------------------------------
        # INTAKE COMPLETE
        # --------------------------------------------------

        if result.get("intake_complete"):

            print()
            print(
                "========== INTAKE COMPLETE =========="
            )

            print(
                "Category :",
                result.get("category"),
            )

            print(
                "Urgency  :",
                result.get("urgency"),
            )

            print(
                "Status   :",
                result.get("status"),
            )

            print()

            break


if __name__ == "__main__":
    main()