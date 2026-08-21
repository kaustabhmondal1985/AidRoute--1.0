from datetime import datetime
from typing import List

from fastapi import APIRouter, HTTPException, Query

from lib.backend.app.appointments.models import (
    Appointment,
    AppointmentCreate,
)
from lib.backend.app.appointments.service import (
    cancel_appointment,
    create_appointment,
    get_appointment,
    get_available_slots,
)

router = APIRouter()


@router.get("/slots", response_model=List[datetime])
def available_slots(
    lawyer_id: str = Query(...),
    date: datetime = Query(...),
):
    return get_available_slots(
        lawyer_id=lawyer_id,
        date=date,
    )


@router.post(
    "",
    response_model=Appointment,
    status_code=201,
)
def book_appointment(
    data: AppointmentCreate,
):
    try:
        appointment = create_appointment(data)
        
        # Send email notification to lawyer
        _send_appointment_email(appointment)
        
        return appointment

    except ValueError as exc:
        raise HTTPException(
            status_code=409,
            detail=str(exc),
        )


def _send_appointment_email(appointment: Appointment):
    """Send email notification to lawyer about new appointment"""
    import os
    import smtplib
    from email.mime.text import MIMEText
    from email.mime.multipart import MIMEMultipart
    
    try:
        # Get email configuration from environment
        smtp_server = os.getenv("SMTP_SERVER", "smtp.gmail.com")
        smtp_port = int(os.getenv("SMTP_PORT", "587"))
        smtp_username = os.getenv("SMTP_USERNAME", "")
        smtp_password = os.getenv("SMTP_PASSWORD", "")
        default_lawyer_email = os.getenv("DEFAULT_LAWYER_EMAIL", "lawyer@aidroute.org")
        
        if not smtp_username or not smtp_password:
            print("[WARNING] SMTP credentials not configured. Skipping email notification.")
            return
        
        # Create email message
        msg = MIMEMultipart()
        msg['From'] = smtp_username
        msg['To'] = default_lawyer_email
        msg['Subject'] = f"New Appointment Booked - {appointment.lawyer_name}"
        
        body = f"""
        New Appointment Details:
        
        Lawyer: {appointment.lawyer_name}
        User ID: {appointment.user_id}
        Category: {appointment.category}
        Appointment Date: {appointment.appointment_date.strftime('%Y-%m-%d %H:%M')}
        Status: {appointment.status}
        Notes: {appointment.notes or 'None'}
        
        Please confirm the appointment with the user.
        """
        
        msg.attach(MIMEText(body, 'plain'))
        
        # Send email
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(smtp_username, smtp_password)
            server.send_message(msg)
        
        print(f"[INFO] Appointment email sent to {default_lawyer_email}")
        
    except Exception as e:
        print(f"[ERROR] Failed to send appointment email: {e}")
        # Don't fail the appointment booking if email fails


@router.get(
    "/{appointment_id}",
    response_model=Appointment,
)
def appointment_details(
    appointment_id: str,
):
    try:
        return get_appointment(appointment_id)

    except ValueError as exc:
        raise HTTPException(
            status_code=404,
            detail=str(exc),
        )


@router.post(
    "/{appointment_id}/cancel",
    response_model=Appointment,
)
def cancel(
    appointment_id: str,
):
    try:
        return cancel_appointment(appointment_id)

    except ValueError as exc:
        raise HTTPException(
            status_code=400,
            detail=str(exc),
        )