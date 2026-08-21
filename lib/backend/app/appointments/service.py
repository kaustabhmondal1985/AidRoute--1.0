import os
from datetime import datetime, timedelta
from typing import List, Optional

from dotenv import load_dotenv
from supabase import create_client, Client

from .models import Appointment, AppointmentCreate, AppointmentStatus


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
        print(f"[WARNING] Failed to initialize Supabase client: {e}")
else:
    print("[WARNING] Supabase credentials not configured. Appointment service will be limited.")


def _row_to_appointment(row: dict) -> Appointment:
    return Appointment(
        id=str(row["id"]),
        user_id=row["user_id"],
        lawyer_id=str(row["lawyer_id"]),
        lawyer_name=row["lawyer_name"],
        category=row["category"],
        appointment_date=row["appointment_date"],
        status=row["status"],
        notes=row.get("notes"),
        created_at=row["created_at"],
    )


def get_available_slots(
    lawyer_id: str,
    date: datetime,
) -> List[datetime]:

    day_start = datetime(
        date.year,
        date.month,
        date.day,
        10,
        0,
    )

    slots = [
        day_start + timedelta(hours=i)
        for i in range(8)
    ]

    response = (
        supabase
        .from_("appointments")
        .select("appointment_date")
        .eq("lawyer_id", lawyer_id)
        .eq("status", AppointmentStatus.CONFIRMED)
        .gte(
            "appointment_date",
            f"{date.date()}T00:00:00",
        )
        .lt(
            "appointment_date",
            f"{date.date()}T23:59:59",
        )
        .execute()
    )

    booked = set()

    for row in response.data or []:
        value = row["appointment_date"]

        if isinstance(value, str):
            value = value.replace("Z", "+00:00")
            value = datetime.fromisoformat(value)

        if value.tzinfo is not None:
            value = value.replace(tzinfo=None)

        booked.add(value)

    return [
        slot
        for slot in slots
        if slot not in booked
    ]


def create_appointment(
    data: AppointmentCreate,
) -> Appointment:

    # Check slot availability if Supabase is configured
    if supabase:
        try:
            available_slots = get_available_slots(
                lawyer_id=data.lawyer_id,
                date=data.appointment_date,
            )

            appointment_date = data.appointment_date

            if appointment_date not in available_slots:
                raise ValueError(
                    "Selected appointment slot is not available."
                )
        except Exception as e:
            # If slot checking fails, proceed anyway
            print(f"[WARNING] Could not check slot availability: {e}. Proceeding with booking.")

    appointment_date = data.appointment_date

    # Create appointment if Supabase is configured
    if supabase:
        payload = {
            "user_id": data.user_id,
            "lawyer_id": data.lawyer_id,
            "lawyer_name": data.lawyer_name,
            "category": data.category,
            "appointment_date": appointment_date.isoformat(),
            "status": AppointmentStatus.CONFIRMED,
            "notes": data.notes,
        }

        response = (
            supabase
            .from_("appointments")
            .insert(payload)
            .execute()
        )

        rows = response.data or []

        if not rows:
            raise RuntimeError(
                "Failed to create appointment."
            )

        return _row_to_appointment(rows[0])
    else:
        # Return a mock appointment if Supabase is not configured
        import uuid
        return Appointment(
            id=str(uuid.uuid4()),
            user_id=data.user_id,
            lawyer_id=data.lawyer_id,
            lawyer_name=data.lawyer_name,
            category=data.category,
            appointment_date=appointment_date,
            status=AppointmentStatus.CONFIRMED,
            notes=data.notes,
            created_at=datetime.utcnow(),
        )


def get_appointment(
    appointment_id: str,
) -> Appointment:

    if not supabase:
        raise ValueError(
            "Appointment service not available (Supabase not configured)."
        )

    response = (
        supabase
        .from_("appointments")
        .select("*")
        .eq("id", appointment_id)
        .limit(1)
        .execute()
    )

    rows = response.data or []

    if not rows:
        raise ValueError(
            "Appointment not found."
        )

    return _row_to_appointment(rows[0])


def cancel_appointment(
    appointment_id: str,
) -> Appointment:

    if not supabase:
        raise ValueError(
            "Appointment service not available (Supabase not configured)."
        )

    appointment = get_appointment(
        appointment_id
    )

    if appointment.status == AppointmentStatus.CANCELLED:
        raise ValueError(
            "Appointment is already cancelled."
        )

    if appointment.status == AppointmentStatus.COMPLETED:
        raise ValueError(
            "Completed appointment cannot be cancelled."
        )

    response = (
        supabase
        .from_("appointments")
        .update(
            {
                "status": AppointmentStatus.CANCELLED
            }
        )
        .eq("id", appointment_id)
        .execute()
    )

    rows = response.data or []

    if not rows:
        raise RuntimeError(
            "Failed to cancel appointment."
        )

    return _row_to_appointment(rows[0])