from typing import List, Optional
from pydantic import BaseModel, Field


ALLOWED_CATEGORIES = {
    "HOUSING_EVICTION",
    "FAMILY",
    "CRIMINAL",
    "CONSUMER",
    "EMPLOYMENT",
}


class Lawyer(BaseModel):
    id: str
    name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    category: str
    specializations: List[str] = Field(default_factory=list)
    city: Optional[str] = None
    state: Optional[str] = None
    experience_years: int = 0
    available: bool = True


class LawyerMatchResponse(BaseModel):
    category: str
    city: Optional[str] = None
    lawyers: List[Lawyer]