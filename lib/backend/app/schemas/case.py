# Placeholder schemas for case
from pydantic import BaseModel

class CaseCreate(BaseModel):
    user_id: str
    details: dict

class CaseResponse(BaseModel):
    case_id: str
    status: str
