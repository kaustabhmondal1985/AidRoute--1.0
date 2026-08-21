import os
from pathlib import Path

from fastapi import FastAPI

from lib.backend.app.api.router import api_router
from lib.backend.app.api.routes import health

app = FastAPI(title="AidRoute Backend")

# Include API router
app.include_router(api_router, prefix="/api")

# Root path (optional)
@app.get("/", include_in_schema=False)
async def root():
    return {"message": "AidRoute backend is running"}
