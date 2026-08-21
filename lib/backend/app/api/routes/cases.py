from typing import Optional

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from lib.backend.app.services.case_orchestrator import analyze_case


router = APIRouter()


class CaseAnalyzeRequest(BaseModel):
    user_message: str = Field(..., min_length=3)
    category: str = Field(..., min_length=1)
    city: Optional[str] = None
    max_lawyers: int = Field(default=5, ge=1, le=20)
    max_chunks: int = Field(default=5, ge=1, le=20)
    language: Optional[str] = Field(default="en")


class CaseAnalyzeResponse(BaseModel):
    category: str
    city: Optional[str] = None

    knowledge_count: int
    knowledge: list

    lawyer_count: int
    lawyers: list

    urgency: str
    urgency_reason: str
    human_review_required: bool

    case_summary: str


@router.get("/")
async def cases_root():
    return {
        "message": "AidRoute Cases API",
        "status": "active",
    }


@router.post("/analyze", response_model=CaseAnalyzeResponse)
async def analyze_case_route(request: CaseAnalyzeRequest):
    try:
        result = analyze_case(
            user_message=request.user_message,
            city=request.city,
            max_lawyers=request.max_lawyers,
            max_chunks=request.max_chunks,
            language=request.language,
        )

        return result

    except ValueError as exc:
        raise HTTPException(
            status_code=400,
            detail=str(exc),
        )

    except Exception as exc:
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500,
            detail=f"Case analysis failed: {str(exc)}",
        )