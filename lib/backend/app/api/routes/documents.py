from typing import List, Optional
from fastapi import APIRouter, UploadFile, File, HTTPException
from pydantic import BaseModel

router = APIRouter()


class DocumentUploadResponse(BaseModel):
    document_id: str
    file_name: str
    status: str
    summary_text: Optional[str] = None
    extracted_dates: Optional[List[dict]] = None


@router.get("/", response_model=dict)
async def documents_root():
    return {"message": "AidRoute Documents API", "status": "active"}


@router.post("/upload", response_model=DocumentUploadResponse)
async def upload_document(
    document: UploadFile = File(...),
    file_name: Optional[str] = None,
    file_type: Optional[str] = None,
):
    try:
        import uuid
        import re
        from datetime import datetime
        from io import BytesIO
        
        document_id = str(uuid.uuid4())
        
        # Read file content
        content = await document.read()
        
        # Try to extract text based on file type
        extracted_text = ""
        if file_type == "application/pdf":
            # For PDF, we'd need PyPDF2 or similar
            # For now, return empty since we don't have PDF processing
            extracted_text = ""
        elif file_type in ["image/jpeg", "image/png", "image/jpg"]:
            # For images, we'd need OCR like pytesseract
            # For now, return empty since we don't have OCR
            extracted_text = ""
        else:
            # Try to decode as text
            try:
                extracted_text = content.decode('utf-8', errors='ignore')
            except:
                extracted_text = ""
        
        # Extract dates from text using regex - more comprehensive patterns
        date_patterns = [
            r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}',  # MM/DD/YYYY or DD/MM/YYYY
            r'\d{4}[/-]\d{1,2}[/-]\d{1,2}',  # YYYY/MM/DD
            r'(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4}',  # Month DD, YYYY
            r'\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4}',  # DD Month YYYY
        ]
        
        dates_found = []
        for pattern in date_patterns:
            dates_found.extend(re.findall(pattern, extracted_text, re.IGNORECASE))
        
        # Remove duplicates while preserving order
        seen = set()
        unique_dates = []
        for date in dates_found:
            if date.lower() not in seen:
                seen.add(date.lower())
                unique_dates.append(date)
        
        # Convert found dates to structured format
        extracted_dates = []
        for idx, date_str in enumerate(unique_dates[:5]):  # Limit to 5 dates
            # Find context around the date
            date_index = extracted_text.lower().find(date_str.lower())
            context_start = max(0, date_index - 50)
            context_end = min(len(extracted_text), date_index + len(date_str) + 50)
            context_snippet = extracted_text[context_start:context_end].strip()
            
            extracted_dates.append({
                "id": f"d{idx+1}",
                "date": date_str,
                "label": f"Date found in document",
                "source_document_name": file_name or document.filename,
                "context_snippet": f"...{context_snippet}..."
            })
        
        # Generate summary based on actual content
        if extracted_dates:
            summary = f"Document processed successfully. Extracted {len(extracted_dates)} date(s) from the document content."
        elif extracted_text.strip():
            summary = f"Document processed successfully. No dates found, but document contains {len(extracted_text.split())} words of text."
        else:
            summary = "Document processed successfully. Document appears to be empty or in a format that requires OCR processing."
        
        return DocumentUploadResponse(
            document_id=document_id,
            file_name=file_name or document.filename,
            status="ready",
            summary_text=summary,
            extracted_dates=extracted_dates if extracted_dates else None
        )
        
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Document upload failed: {str(exc)}",
        )
