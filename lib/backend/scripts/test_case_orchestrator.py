from lib.backend.app.services.case_orchestrator import analyze_case


def main():
    print("[INFO] Testing AidRoute case orchestrator...")
    print()

    user_message = "My landlord is trying to evict me from my rented home."
    category = "HOUSING_EVICTION"
    city = "Mumbai"

    print("[INFO] User message:")
    print(user_message)
    print()

    print("[INFO] Category:", category)
    print("[INFO] City:", city)
    print()

    result = analyze_case(
        user_message=user_message,
        category=category,
        city=city,
        max_lawyers=5,
        max_chunks=5,
    )

    print("[OK] Case orchestration completed.")
    print()

    print("========== CASE ==========")
    print("Category :", result["category"])
    print("City     :", result["city"])
    print()

    print("========== RAG ==========")
    print("Knowledge chunks:", result["knowledge_count"])
    print()

    for index, item in enumerate(result["knowledge"], start=1):
        print(f"--- Knowledge {index} ---")
        print("Source     :", item.get("source"))
        print("Category   :", item.get("category"))
        print("Similarity :", item.get("similarity"))
        print("Content    :", item.get("content"))
        print()

    print("========== LAWYERS ==========")
    print("Lawyers found:", result["lawyer_count"])
    print()

    for index, lawyer in enumerate(result["lawyers"], start=1):
        print(f"--- Lawyer {index} ---")
        print("Name       :", lawyer.get("name"))
        print("City       :", lawyer.get("city"))
        print("Category   :", lawyer.get("category"))
        print("Experience :", lawyer.get("experience_years"), "years")
        print("Available  :", lawyer.get("available"))
        print()

    print("[OK] End-to-end case orchestration test passed.")


if __name__ == "__main__":
    main()