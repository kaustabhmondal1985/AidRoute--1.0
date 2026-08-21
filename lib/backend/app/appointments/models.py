from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class AppointmentStatus:
    PENDING = "pending"
    CONFIRMED = "confirmed"
    CANCELLED = "cancelled"
    COMPLETED = "completed"


class Appointment(BaseModel):
    id: str
    user_id: str
    lawyer_id: str
    lawyer_name: str
    category: str
    appointment_date: datetime
    status: str = AppointmentStatus.PENDING
    notes: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)


class AppointmentCreate(BaseModel):
    user_id: str
    lawyer_id: str
    lawyer_name: str
    category: str
    appointment_date: datetime
    notes: Optional[str] = None


class AppointmentResponse(BaseModel):
    id: str
    user_id: str
    lawyer_id: str
    lawyer_name: str
    category: str
    appointment_date: datetime
    status: str
    notes: Optional[str] = None
    created_at: datetime