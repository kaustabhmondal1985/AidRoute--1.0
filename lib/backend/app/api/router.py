from fastapi import APIRouter

from lib.backend.app.api.routes import health
from lib.backend.app.api.routes import intake
from lib.backend.app.api.routes import documents
from lib.backend.app.api.routes import cases
from lib.backend.app.api.routes import legal_info
from lib.backend.app.api import lawyers
from lib.backend.app.api import appointments


api_router = APIRouter()


api_router.include_router(
    health.router,
    prefix="/health",
    tags=["Health"],
)

api_router.include_router(
    intake.router,
    prefix="/intake",
    tags=["Intake"],
)

api_router.include_router(
    documents.router,
    prefix="/documents",
    tags=["Documents"],
)

api_router.include_router(
    cases.router,
    prefix="/cases",
    tags=["Cases"],
)

api_router.include_router(
    legal_info.router,
    prefix="/legal-info",
    tags=["Legal Information"],
)

api_router.include_router(
    lawyers.router,
    prefix="/lawyers",
    tags=["Lawyers"],
)

api_router.include_router(
    appointments.router,
    prefix="/appointments",
    tags=["Appointments"],
)