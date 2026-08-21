from fastapi import APIRouter

router = APIRouter()

@router.get("/", response_model=dict)
async def health_check():
    return {"status": "ok"}
