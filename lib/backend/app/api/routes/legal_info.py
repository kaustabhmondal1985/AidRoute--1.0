from typing import Optional
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from lib.backend.app.agents.legal_info_agent import LegalInfoAgent


router = APIRouter()


class LegalInfoRequest(BaseModel):
    query: str = Field(..., min_length=3)
    category: Optional[str] = None
    top_k: int = Field(default=5, ge=1, le=20)


class LegalInfoResponse(BaseModel):
    query: str
    category: str
    answer: str
    legal_information: str
    sources: list
    knowledge_chunks: int


@router.get("/")
async def legal_info_root():
    return {"message": "AidRoute Legal Information API", "status": "active"}


@router.post("/generate", response_model=LegalInfoResponse)
async def generate_legal_info(request: LegalInfoRequest):
    try:
        agent = LegalInfoAgent()
        
        result = agent.generate(
            query=request.query,
            category=request.category or "GENERAL",
            top_k=request.top_k,
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
            detail=f"Legal information generation failed: {str(exc)}",
        )
