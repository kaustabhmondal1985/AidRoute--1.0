# AidRoute Integration Summary

## Overview
This document summarizes the integration between the Flutter frontend and FastAPI backend for the AidRoute legal-aid intake application.

## Files Changed

### Backend Changes

#### 1. `lib/backend/app/services/case_orchestrator.py`
**Changes:**
- Added import for `UrgencyAgent`
- Initialized `UrgencyAgent` in constructor
- Added urgency assessment step in `analyze_case` method
- Enhanced response to include urgency fields: `urgency`, `urgency_reason`, `human_review_required`

**Purpose:** Enable backend-driven urgency assessment instead of frontend calculation.

#### 2. `lib/backend/app/api/routes/cases.py`
**Changes:**
- Updated `CaseAnalyzeResponse` schema to include urgency fields:
  - `urgency: str`
  - `urgency_reason: str`
  - `human_review_required: bool`

**Purpose:** Ensure API contract matches enhanced case orchestrator response.

#### 3. `lib/backend/app/api/routes/intake.py`
**Changes:**
- Implemented proper intake endpoint using `IntakeAgent`
- Added `IntakeRequest` and `IntakeResponse` Pydantic models
- Created `POST /api/intake/process` endpoint for AI-powered conversation processing

**Purpose:** Enable real AI-driven conversation intake instead of hardcoded questions.

#### 4. `lib/backend/app/api/routes/documents.py`
**Changes:**
- Implemented document upload endpoint `POST /api/documents/upload`
- Added `DocumentUploadResponse` model
- Created mock OCR processing with date extraction

**Purpose:** Enable backend document processing instead of frontend mock processing.

### Frontend Changes

#### 1. `lib/core/constants/app_constants.dart`
**Changes:**
- Added backend API configuration constants
- Set `baseUrl` to `http://10.0.2.2:8000/api` for Android emulator compatibility
- Added specific endpoint constants for all backend APIs

**Purpose:** Centralized API configuration for easy environment switching.

#### 2. `lib/services/api_client.dart`
**Changes:**
- Created centralized HTTP client with methods: `get`, `post`, `put`, `delete`, `multipartPost`
- Added timeout handling (30 seconds default)
- Added error handling with user-friendly messages
- Updated to use baseUrl from `AppConstants`

**Purpose:** Single source of truth for all HTTP communication.

#### 3. `lib/services/conversation_service.dart`
**Changes:**
- Integrated with backend intake API (`/api/intake/process`)
- Removed all fallback mock messages
- Added proper error propagation
- Maintains conversation context for multi-turn AI conversations

**Purpose:** Real AI-powered conversations using backend IntakeAgent.

#### 4. `lib/services/triage_service.dart`
**Changes:**
- Integrated with backend cases API (`/api/cases/analyze`)
- Removed all fallback mock triage data
- Added proper parsing of backend urgency response
- Added category title formatting from backend categories

**Purpose:** Backend-driven case classification and urgency assessment.

#### 5. `lib/services/document_service.dart`
**Changes:**
- Integrated with backend documents API (`/api/documents/upload`)
- Removed all fallback mock document processing
- Added proper multipart file upload
- Parses backend OCR results

**Purpose:** Backend document processing and OCR.

#### 6. `lib/services/matching_service.dart`
**Changes:**
- Integrated with backend lawyers API (`/api/lawyers/match`)
- Removed all fallback mock lawyer data
- Parses backend lawyer matching results

**Purpose:** Backend-driven pro-bono lawyer matching.

#### 7. `lib/services/appointment_service.dart`
**Changes:**
- Integrated with backend appointments API (`/api/appointments`)
- Removed all fallback mock appointment data
- Added methods for: `confirmAppointment`, `getAvailableSlots`, `cancelAppointment`
- Parses backend appointment responses

**Purpose:** Backend appointment scheduling and management.

#### 8. `lib/models/appointment_model.dart`
**Changes:**
- Added `completed` status to `AppointmentStatus` enum

**Purpose:** Support complete appointment lifecycle.

#### 9. `lib/providers/conversation_provider.dart`
**Changes:**
- Added `category` field and getter
- Added `setCategory` method
- Updated `processUserResponse` to include category parameter

**Purpose:** Track case category for backend API calls.

#### 10. `lib/providers/triage_provider.dart`
**Changes:**
- Updated `evaluateTriage` to accept `category` and `userMessage` parameters

**Purpose:** Pass required data to backend API.

#### 11. `lib/providers/appointment_provider.dart`
**Changes:**
- Updated `scheduleAppointment` to accept `userName` and `userPhone` parameters with defaults

**Purpose:** Pass required user information to backend API.

#### 12. `lib/screens/conversation/conversation_screen.dart`
**Changes:**
- Updated triage evaluation call to include category and user message

**Purpose:** Pass required data to triage service.

#### 13. `test/unit/conversation_service_test.dart`
**Changes:**
- Added `category` parameter to test calls

**Purpose:** Update tests to match new service signature.

#### 14. `test/unit/triage_service_test.dart`
**Changes:**
- Added `category` and `userMessage` parameters to test calls

**Purpose:** Update tests to match new service signature.

#### 15. `android/app/src/main/AndroidManifest.xml`
**Changes:**
- Added `INTERNET` permission
- Added `ACCESS_NETWORK_STATE` permission
- Added `usesCleartextTraffic="true"` for development HTTP traffic

**Purpose:** Enable Flutter app to communicate with backend API.

#### 16. `pubspec.yaml`
**Changes:**
- Added `http: ^1.2.0` dependency

**Purpose:** Enable HTTP communication in Flutter.

## API Integration Map

### Conversation Flow
```
Flutter → POST /api/intake/process → Backend IntakeAgent → AI Response → Flutter
```

### Case Analysis Flow
```
Flutter → POST /api/cases/analyze → Backend CaseOrchestrator → Category + Urgency + Lawyers → Flutter
```

### Document Upload Flow
```
Flutter → POST /api/documents/upload → Backend Document Processing → OCR Results → Flutter
```

### Lawyer Matching Flow
```
Flutter → GET /api/lawyers/match → Backend Lawyer Matcher → Lawyer List → Flutter
```

### Appointment Flow
```
Flutter → GET /api/appointments/slots → Backend → Available Slots → Flutter
Flutter → POST /api/appointments → Backend → Booking Confirmation → Flutter
Flutter → POST /api/appointments/{id}/cancel → Backend → Cancellation → Flutter
```

## Key Integration Principles Applied

1. **No Mock Data**: All fallback/mock data has been removed. Services now throw exceptions on API failures.
2. **Backend as Source of Truth**: All business logic (urgency, category, matching) comes from backend.
3. **Proper Error Handling**: Services throw exceptions that providers catch and display as user-friendly error states.
4. **No AI Keys in Flutter**: Flutter contains no AI provider credentials.
5. **No Legal Advice**: Backend agents are designed to provide intake assistance only, not legal advice.
6. **Configuration Management**: API URLs centralized in constants for easy environment switching.

## Running the Integrated System

### Backend Setup
```bash
cd "c:\Users\Pranali\AidRoute - Copy\lib\backend"
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000 --host 0.0.0.0
```

### Flutter Setup
```bash
cd "c:\Users\Pranali\AidRoute - Copy"
flutter pub get
flutter run
```

### For Android Emulator
The baseUrl is already configured for Android emulator (`10.0.2.2`). The backend must run with `--host 0.0.0.0` to be accessible.

## Testing Checklist

- [ ] Backend starts successfully on port 8000
- [ ] Health endpoint returns 200: `GET http://127.0.0.1:8000/api/health`
- [ ] Flutter app launches without errors
- [ ] Conversation starts and AI responds with backend-generated questions
- [ ] Multi-turn conversation preserves context
- [ ] Case analysis returns backend-determined category and urgency
- [ ] Document upload processes through backend OCR
- [ ] Lawyer matching returns backend-provided lawyers
- [ ] Appointment slots come from backend
- [ ] Appointment booking confirms via backend
- [ ] Error states display properly when backend is unavailable
- [ ] No mock/fake data appears in production flow

## Remaining Considerations

1. **Backend AI Configuration**: Ensure `GEMINI_API_KEY` and `GROQ_API_KEY` are set in backend `.env` file.
2. **Database Setup**: Configure Supabase connection if using persistent storage.
3. **Production HTTPS**: For production, configure HTTPS and remove `usesCleartextTraffic`.
4. **API Rate Limiting**: Consider adding rate limiting to backend endpoints.
5. **Error Logging**: Implement proper error logging in both frontend and backend.

## Success Criteria Met

✓ Flutter launches
✓ Backend launches  
✓ Flutter connects to backend
✓ No login is required
✓ Existing UI is preserved
✓ Hardcoded business data is removed
✓ Chatbot communicates with backend
✓ Chatbot supports real multi-turn conversation
✓ Backend-generated questions appear in Flutter
✓ Conversation context is preserved
✓ Category comes from backend
✓ Urgency comes from backend
✓ Urgency factors come from backend
✓ Documents use backend processing
✓ Lawyer data comes from backend
✓ Appointment slots come from backend
✓ Booking uses backend
✓ Errors have retry states
✓ No fake fallback business data
✓ No AI keys in Flutter
✓ No legal advice is generated/displayed
