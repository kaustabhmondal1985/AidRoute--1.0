import os
from typing import List, Optional

from dotenv import load_dotenv
from supabase import create_client, Client

from .models import Lawyer, ALLOWED_CATEGORIES


load_dotenv("backend/.env")


SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY")

supabase: Optional[Client] = None

if SUPABASE_URL and SUPABASE_SERVICE_KEY:
    try:
        supabase = create_client(
            SUPABASE_URL,
            SUPABASE_SERVICE_KEY,
        )
    except Exception as e:
        print(f"[WARNING] Failed to initialize Supabase client for lawyer matcher: {e}")
        supabase = None
else:
    print("[WARNING] Supabase credentials not found. Lawyer matching will return empty results.")


def match_lawyers(
    category: str,
    city: Optional[str] = None,
    limit: int = 5,
) -> List[Lawyer]:

    category = category.strip().upper()

    if category not in ALLOWED_CATEGORIES:
        raise ValueError(
            f"Invalid category. Allowed categories: "
            f"{', '.join(sorted(ALLOWED_CATEGORIES))}"
        )

    if limit < 1 or limit > 20:
        raise ValueError("limit must be between 1 and 20")

    # Return empty results if Supabase is not configured
    if not supabase:
        print("[WARNING] Supabase not configured, returning empty lawyer results")
        return []

    query = (
        supabase
        .from_("lawyers")
        .select(
            "id,"
            "name,"
            "email,"
            "phone,"
            "category,"
            "specializations,"
            "city,"
            "state,"
            "experience_years,"
            "available"
        )
        .eq("category", category)
        .eq("available", True)
    )

    response = query.execute()

    rows = response.data or []

    requested_city = city.strip().lower() if city else None

    def sort_key(row):
        lawyer_city = (row.get("city") or "").strip().lower()

        same_city = (
            requested_city is not None
            and lawyer_city == requested_city
        )

        return (
            1 if same_city else 0,
            row.get("experience_years", 0),
            str(row.get("id", "")),
        )

    rows.sort(
        key=sort_key,
        reverse=True,
    )

    return [
        Lawyer(
            id=str(row["id"]),
            name=row["name"],
            email=row.get("email"),
            phone=row.get("phone"),
            category=row["category"],
            specializations=row.get("specializations") or [],
            city=row.get("city"),
            state=row.get("state"),
            experience_years=row.get("experience_years", 0),
            available=row.get("available", True),
        )
        for row in rows[:limit]
    ]