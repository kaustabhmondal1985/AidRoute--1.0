
from typing import Optional

from fastapi import APIRouter, HTTPException, Query

from lib.backend.app.lawyers.matcher import match_lawyers
from lib.backend.app.lawyers.models import (
    LawyerMatchResponse,
    ALLOWED_CATEGORIES,
)


router = APIRouter()


@router.get(
    "/match",
    response_model=LawyerMatchResponse,
)
def get_matching_lawyers(
    category: str = Query(...),
    city: Optional[str] = Query(None),
    limit: int = Query(5, ge=1, le=20),
):
    category = category.strip().upper()

    # Map common category variations to allowed categories
    category_mapping = {
        "HOUSING": "HOUSING_EVICTION",
        "EMPLOYMENT_LABOR": "EMPLOYMENT",
        "FAMILY_LAW": "FAMILY",
    }
    
    if category in category_mapping:
        category = category_mapping[category]

    if category not in ALLOWED_CATEGORIES:
        raise HTTPException(
            status_code=400,
            detail={
                "message": "Invalid lawyer category.",
                "allowed_categories": sorted(ALLOWED_CATEGORIES),
                "received_category": category,
            },
        )

    try:
        lawyers = match_lawyers(
            category=category,
            city=city,
            limit=limit,
        )

        return LawyerMatchResponse(
            category=category,
            city=city,
            lawyers=lawyers,
        )

    except ValueError as exc:
        raise HTTPException(
            status_code=400,
            detail=str(exc),
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unable to retrieve matching lawyers.",
        )