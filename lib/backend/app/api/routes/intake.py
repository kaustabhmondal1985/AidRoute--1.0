from typing import List, Optional, Dict, Any
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

from lib.backend.app.agents.intake_agent import IntakeAgent


router = APIRouter()


class IntakeRequest(BaseModel):
    category: str = Field(..., min_length=1)
    user_message: str = Field(..., min_length=1)
    case_facts: Optional[List[str]] = Field(default_factory=list)
    messages: Optional[List[Dict[str, str]]] = Field(default_factory=list)
    documents: Optional[List[Dict[str, Any]]] = Field(default_factory=list)


class IntakeResponse(BaseModel):
    intake_complete: bool
    missing_information: List[str]
    pending_question: Optional[str]
    case_facts: List[str]


@router.get("/", response_model=dict)
async def intake_root():
    return {"message": "AidRoute Intake API", "status": "active"}


@router.post("/process", response_model=IntakeResponse)
async def process_intake(request: IntakeRequest):
    try:
        agent = IntakeAgent()
        
        result = agent.assess(
            category=request.category,
            user_message=request.user_message,
            case_facts=request.case_facts,
            messages=request.messages,
            documents=request.documents,
        )
        
        return IntakeResponse(
            intake_complete=result["intake_complete"],
            missing_information=result["missing_information"],
            pending_question=result["pending_question"],
            case_facts=result.get("extracted_facts", []),
        )
    
    except ValueError as exc:
        raise HTTPException(
            status_code=400,
            detail=str(exc),
        )
    
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Intake processing failed: {str(exc)}",
        )
