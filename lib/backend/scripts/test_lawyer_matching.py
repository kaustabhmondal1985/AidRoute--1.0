from lib.backend.app.lawyers.matcher import match_lawyers


def main():
    print("[INFO] Testing AidRoute lawyer matching...")

    print("\n[TEST 1] Housing + Mumbai")

    lawyers = match_lawyers(
        category="HOUSING_EVICTION",
        city="Mumbai",
        limit=5,
    )

    assert len(lawyers) <= 5

    for lawyer in lawyers:
        print(
            f"- {lawyer.name} | "
            f"{lawyer.city} | "
            f"{lawyer.experience_years} years"
        )

    print("[OK] Housing matching works.")

    print("\n[TEST 2] Family + Mumbai")

    lawyers = match_lawyers(
        category="FAMILY",
        city="Mumbai",
        limit=5,
    )

    assert len(lawyers) <= 5

    for lawyer in lawyers:
        print(
            f"- {lawyer.name} | "
            f"{lawyer.city} | "
            f"{lawyer.experience_years} years"
        )

    print("[OK] Family matching works.")

    print("\n[TEST 3] Criminal + Mumbai")

    lawyers = match_lawyers(
        category="CRIMINAL",
        city="Mumbai",
        limit=5,
    )

    assert len(lawyers) <= 5

    for lawyer in lawyers:
        print(
            f"- {lawyer.name} | "
            f"{lawyer.city} | "
            f"{lawyer.experience_years} years"
        )

    print("[OK] Criminal matching works.")

    print("\n[TEST 4] Invalid category")

    try:
        match_lawyers(
            category="INVALID_CATEGORY",
            city="Mumbai",
        )
        raise AssertionError("Invalid category was accepted.")

    except ValueError:
        print("[OK] Invalid category rejected.")

    print("\n[TEST 5] Invalid limit")

    try:
        match_lawyers(
            category="FAMILY",
            city="Mumbai",
            limit=21,
        )
        raise AssertionError("Invalid limit was accepted.")

    except ValueError:
        print("[OK] Invalid limit rejected.")

    print("\n[OK] Lawyer matching test passed.")


if __name__ == "__main__":
    main()