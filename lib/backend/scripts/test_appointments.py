from datetime import datetime

from lib.backend.app.appointments.models import AppointmentCreate
from lib.backend.app.appointments.service import (
    cancel_appointment,
    create_appointment,
    get_appointment,
    get_available_slots,
)


def main():
    print("[INFO] Testing AidRoute appointment service...")

    lawyer_id = "lawyer_1"

    appointment_date = datetime(
        2026,
        8,
        25,
        10,
        0,
    )

    print("\n[TEST 1] Get available slots")

    slots = get_available_slots(
        lawyer_id=lawyer_id,
        date=appointment_date,
    )

    print(f"[INFO] Available slots: {len(slots)}")

    assert len(slots) == 8

    print("[OK] Slot generation works.")

    print("\n[TEST 2] Create appointment")

    data = AppointmentCreate(
        user_id="user_1",
        lawyer_id=lawyer_id,
        lawyer_name="Aarav Mehta",
        category="HOUSING_EVICTION",
        appointment_date=appointment_date,
    )

    appointment = create_appointment(data)

    print(f"[INFO] Appointment ID: {appointment.id}")
    print(f"[INFO] Status: {appointment.status}")

    assert appointment.status == "confirmed"

    print("[OK] Appointment creation works.")

    print("\n[TEST 3] Booked slot disappears")

    slots_after_booking = get_available_slots(
        lawyer_id=lawyer_id,
        date=appointment_date,
    )

    assert appointment_date not in slots_after_booking
    assert len(slots_after_booking) == 7

    print("[OK] Booked slot is unavailable.")

    print("\n[TEST 4] Retrieve appointment")

    retrieved = get_appointment(appointment.id)

    assert retrieved.id == appointment.id

    print("[OK] Appointment retrieval works.")

    print("\n[TEST 5] Cancel appointment")

    cancelled = cancel_appointment(
        appointment.id
    )

    assert cancelled.status == "cancelled"

    print("[OK] Appointment cancellation works.")

    print("\n[TEST 6] Cancelled slot becomes available")

    slots_after_cancel = get_available_slots(
        lawyer_id=lawyer_id,
        date=appointment_date,
    )

    assert appointment_date in slots_after_cancel

    print("[OK] Cancelled slot is available again.")

    print("\n[OK] All appointment service tests passed.")


if __name__ == "__main__":
    main()