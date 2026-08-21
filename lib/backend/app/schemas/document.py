# Placeholder schema for a Document
from pydantic import BaseModel

class DocumentCreate(BaseModel):
    filename: str
    content_type: str
    data: bytes

class DocumentResponse(BaseModel):
    document_id: str
    status: str
