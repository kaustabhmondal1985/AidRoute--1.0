# AidRoute --- Mobile Frontend

> **Smart Legal-Aid Intake & Triage Companion**

AidRoute is a Flutter-based conversational mobile application for
legal-aid intake and triage. It collects a person's situation through an
adaptive multi-turn conversation, identifies the likely legal category
and urgency, creates a structured case summary, and routes the case to
appropriate legal-aid staff or volunteer lawyers through the backend
workflow.

## Critical Product Boundary

AidRoute is **strictly an intake and routing tool**.

The mobile application must **never provide legal advice**, recommend a
legal strategy, interpret the law for the user, or present a legal
conclusion as professional advice.

The application may:

-   collect information;
-   ask adaptive intake questions;
-   classify the case into an approved legal category;
-   determine and display an urgency level returned by the backend;
-   explain which user-provided facts contributed to the urgency
    decision;
-   collect and display documents;
-   display extracted dates and document information;
-   perform basic eligibility pre-screening;
-   present routing or matching information;
-   help with appointment scheduling.

The application must not:

-   tell a user what legal action they should take;
-   tell a user what their legal rights or legal outcome are;
-   act as a lawyer;
-   generate legal advice;
-   invent legal rules;
-   substitute an AI-generated opinion for a qualified legal
    professional.

------------------------------------------------------------------------

# 1. Problem

People seeking free legal help often do not know:

-   how urgent their situation is;
-   what type of legal help they may need;
-   what information a legal-aid clinic needs before reviewing their
    case.

Static intake forms can miss important context. Time-sensitive
situations such as imminent evictions or court deadlines can therefore
remain buried in a normal queue.

AidRoute addresses this by using a conversational intake process that
can ask follow-up questions based on the user's responses and identify
cases that require faster human attention.

------------------------------------------------------------------------

# 2. Product Goal

The mobile application should provide a simple conversational journey:

``` text
Start
  ↓
Choose Language
  ↓
Begin Intake
  ↓
Describe Situation
  ↓
Adaptive AI Questions
  ↓
Identify Legal Category
  ↓
Determine Urgency
  ↓
Explain Urgency Factors
  ↓
Upload Supporting Documents
  ↓
Extract Important Information
  ↓
Review Case Information
  ↓
Eligibility Pre-Screening
  ↓
Routing / Lawyer Matching
  ↓
Schedule Consultation (when available)
  ↓
Submit Case
  ↓
Urgent Escalation / Normal Routing
  ↓
Confirmation
```

------------------------------------------------------------------------

# 3. Mobile Frontend Responsibilities

The `mobile/` application is responsible for the user-facing experience.

## Core Responsibilities

1.  Application startup
2.  Language selection
3.  Conversational intake
4.  Adaptive multi-turn questioning
5.  Collection of structured answers
6.  Display of case category
7.  Display of urgency
8.  Display of urgency explanation
9.  Document selection and upload
10. Document processing status
11. Display of extracted important dates
12. Structured case-summary review
13. Eligibility pre-screening
14. Routing status
15. Lawyer matching information
16. Appointment scheduling
17. Urgent-case escalation status
18. Submission
19. Confirmation
20. Loading, error, retry, and empty states
21. Accessibility and multilingual UI

------------------------------------------------------------------------

# 4. Architecture

The mobile application follows a layered architecture:

``` text
┌─────────────────────────────────────────────┐
│                 Flutter UI                  │
│                                             │
│ Screens + Widgets + Forms + Conversation    │
└──────────────────────┬──────────────────────┘
                       ↓
┌─────────────────────────────────────────────┐
│              State Management               │
│                                             │
│ App / Intake / Chat / Document / Case       │
└──────────────────────┬──────────────────────┘
                       ↓
┌─────────────────────────────────────────────┐
│                   Services                  │
│                                             │
│ Auth / Intake / Chat / Document / Case      │
│ Eligibility / Matching / Scheduling         │
└──────────────────────┬──────────────────────┘
                       ↓
┌─────────────────────────────────────────────┐
│                 API Client                  │
└──────────────────────┬──────────────────────┘
                       ↓
┌─────────────────────────────────────────────┐
│                 Backend API                 │
│                                             │
│ Agentic AI / Triage / RAG / OCR / Routing   │
│ Notifications / Matching / Scheduling       │
└─────────────────────────────────────────────┘
```

## Important Boundary

The Flutter app must not directly access:

-   Gemini or another model provider using secret credentials;
-   the production database;
-   private RAG indexes;
-   backend agent internals;
-   backend-only service credentials.

The expected interaction is:

``` text
Flutter → Backend API → AI / RAG / OCR / Database / Routing
```

------------------------------------------------------------------------

# 5. Complete Frontend Directory

``` text
mobile/
│
├── android/
├── ios/
├── web/
│
├── assets/
│   ├── images/
│   ├── icons/
│   ├── fonts/
│   └── translations/
│
├── lib/
│   │
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── api_constants.dart
│   │   │   ├── route_constants.dart
│   │   │   └── text_constants.dart
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_dimensions.dart
│   │   │
│   │   ├── routes/
│   │   │   ├── app_router.dart
│   │   │   └── route_names.dart
│   │   │
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── api_response.dart
│   │   │   ├── network_exception.dart
│   │   │   └── api_error_handler.dart
│   │   │
│   │   ├── localization/
│   │   │   ├── localization_service.dart
│   │   │   └── supported_languages.dart
│   │   │
│   │   ├── validation/
│   │   │   ├── field_validators.dart
│   │   │   ├── file_validators.dart
│   │   │   └── intake_validators.dart
│   │   │
│   │   └── widgets/
│   │       ├── app_button.dart
│   │       ├── app_text_field.dart
│   │       ├── app_loader.dart
│   │       ├── app_error.dart
│   │       ├── app_dialog.dart
│   │       ├── app_card.dart
│   │       └── app_status_badge.dart
│   │
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── language_model.dart
│   │   ├── intake_model.dart
│   │   ├── question_model.dart
│   │   ├── answer_model.dart
│   │   ├── message_model.dart
│   │   ├── conversation_model.dart
│   │   ├── legal_category_model.dart
│   │   ├── urgency_model.dart
│   │   ├── urgency_factor_model.dart
│   │   ├── document_model.dart
│   │   ├── document_analysis_model.dart
│   │   ├── extracted_date_model.dart
│   │   ├── eligibility_model.dart
│   │   ├── lawyer_model.dart
│   │   ├── lawyer_match_model.dart
│   │   ├── appointment_model.dart
│   │   ├── case_summary_model.dart
│   │   ├── routing_model.dart
│   │   ├── escalation_model.dart
│   │   └── submission_model.dart
│   │
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── intake_service.dart
│   │   ├── conversation_service.dart
│   │   ├── triage_service.dart
│   │   ├── rag_service.dart
│   │   ├── document_service.dart
│   │   ├── eligibility_service.dart
│   │   ├── matching_service.dart
│   │   ├── appointment_service.dart
│   │   ├── notification_service.dart
│   │   ├── case_service.dart
│   │   └── submission_service.dart
│   │
│   ├── providers/
│   │   ├── app_provider.dart
│   │   ├── auth_provider.dart
│   │   ├── language_provider.dart
│   │   ├── intake_provider.dart
│   │   ├── conversation_provider.dart
│   │   ├── triage_provider.dart
│   │   ├── document_provider.dart
│   │   ├── eligibility_provider.dart
│   │   ├── matching_provider.dart
│   │   ├── appointment_provider.dart
│   │   ├── case_provider.dart
│   │   └── submission_provider.dart
│   │
│   ├── screens/
│   │   │
│   │   ├── splash/
│   │   │   ├── splash_screen.dart
│   │   │   └── splash_controller.dart
│   │   │
│   │   ├── language/
│   │   │   ├── language_screen.dart
│   │   │   └── language_controller.dart
│   │   │
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── home_controller.dart
│   │   │
│   │   ├── intake/
│   │   │   ├── intake_screen.dart
│   │   │   ├── intake_controller.dart
│   │   │   └── widgets/
│   │   │       ├── intake_field.dart
│   │   │       ├── intake_progress.dart
│   │   │       └── intake_section.dart
│   │   │
│   │   ├── conversation/
│   │   │   ├── conversation_screen.dart
│   │   │   ├── conversation_controller.dart
│   │   │   └── widgets/
│   │   │       ├── message_bubble.dart
│   │   │       ├── message_input.dart
│   │   │       ├── typing_indicator.dart
│   │   │       ├── question_card.dart
│   │   │       ├── option_selector.dart
│   │   │       └── conversation_progress.dart
│   │   │
│   │   ├── triage/
│   │   │   ├── triage_screen.dart
│   │   │   ├── triage_controller.dart
│   │   │   └── widgets/
│   │   │       ├── category_card.dart
│   │   │       ├── urgency_card.dart
│   │   │       ├── urgency_factor_card.dart
│   │   │       └── explanation_panel.dart
│   │   │
│   │   ├── document_upload/
│   │   │   ├── document_upload_screen.dart
│   │   │   ├── document_upload_controller.dart
│   │   │   └── widgets/
│   │   │       ├── document_card.dart
│   │   │       ├── file_picker_button.dart
│   │   │       ├── upload_progress.dart
│   │   │       └── document_status.dart
│   │   │
│   │   ├── document_review/
│   │   │   ├── document_review_screen.dart
│   │   │   ├── document_review_controller.dart
│   │   │   └── widgets/
│   │   │       ├── extracted_date_card.dart
│   │   │       ├── extracted_information.dart
│   │   │       └── document_warning.dart
│   │   │
│   │   ├── eligibility/
│   │   │   ├── eligibility_screen.dart
│   │   │   ├── eligibility_controller.dart
│   │   │   └── widgets/
│   │   │       ├── eligibility_question.dart
│   │   │       └── eligibility_result.dart
│   │   │
│   │   ├── matching/
│   │   │   ├── lawyer_matching_screen.dart
│   │   │   ├── lawyer_matching_controller.dart
│   │   │   └── widgets/
│   │   │       ├── lawyer_card.dart
│   │   │       ├── specialty_badge.dart
│   │   │       └── availability_badge.dart
│   │   │
│   │   ├── appointment/
│   │   │   ├── appointment_screen.dart
│   │   │   ├── appointment_controller.dart
│   │   │   └── widgets/
│   │   │       ├── date_selector.dart
│   │   │       ├── time_slot.dart
│   │   │       └── appointment_summary.dart
│   │   │
│   │   ├── case_summary/
│   │   │   ├── case_summary_screen.dart
│   │   │   ├── case_summary_controller.dart
│   │   │   └── widgets/
│   │   │       ├── case_section.dart
│   │   │       ├── summary_field.dart
│   │   │       ├── urgency_summary.dart
│   │   │       └── routing_summary.dart
│   │   │
│   │   ├── submission/
│   │   │   ├── submission_screen.dart
│   │   │   ├── submission_controller.dart
│   │   │   └── widgets/
│   │   │       ├── review_item.dart
│   │   │       └── submission_status.dart
│   │   │
│   │   └── confirmation/
│   │       ├── confirmation_screen.dart
│   │       └── confirmation_controller.dart
│   │
│   └── widgets/
│       ├── common/
│       ├── conversation/
│       ├── documents/
│       ├── triage/
│       ├── matching/
│       └── case/
│
├── test/
│   ├── models/
│   ├── services/
│   ├── providers/
│   ├── screens/
│   └── widgets/
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

------------------------------------------------------------------------

# 6. Feature Classification

## Compulsory Features

These are required for the core AidRoute product:

-   Adaptive multi-turn intake
-   Agentic AI conversation
-   Legal-category determination
-   Urgency determination
-   Reasoning over conversation context
-   Retrieval of approved intake definitions through RAG
-   Structured case summary
-   Proactive escalation of genuinely time-sensitive cases
-   Explanation of information that caused the urgency decision
-   Strict no-legal-advice boundary

## Bonus Features

The following are optional enhancements:

-   Document Intelligence
-   Multilingual Intake
-   Automated Notifications
-   Lawyer Matching
-   Appointment Scheduling
-   Eligibility Pre-Screening

The frontend architecture includes extension points for all bonus
features without making them inseparable from the core intake flow.

------------------------------------------------------------------------

# 7. Screen-by-Screen Decomposition

## 7.1 Splash Screen

### Purpose

Initialize the application and determine where the user should enter the
flow.

### Responsibilities

-   Load application configuration
-   Restore required local state
-   Load saved language
-   Check active case/session when applicable
-   Navigate to the appropriate starting screen

### Functions

``` dart
initializeApp()
restoreApplicationState()
loadLanguage()
checkActiveSession()
navigateToStart()
```

------------------------------------------------------------------------

# 7.2 Language Selection

### Purpose

Allow users to select their preferred intake language.

### Responsibilities

-   Display supported languages
-   Persist selected language
-   Update application localization
-   Start intake using selected language

### Functions

``` dart
loadSupportedLanguages()
selectLanguage()
saveLanguage()
applyLanguage()
continueToHome()
```

### Multilingual Requirement

The conversation and user-facing intake flow should be capable of
operating in supported languages.

The frontend should not assume English-only labels, messages, validation
text, or question rendering.

------------------------------------------------------------------------

# 7.3 Home

### Purpose

Introduce the application and start or resume an intake.

### Responsibilities

-   Explain that AidRoute is an intake and routing companion
-   Clearly communicate the no-legal-advice boundary
-   Start a new intake
-   Resume an existing intake when supported

### Functions

``` dart
startNewIntake()
resumeIntake()
showProductDisclaimer()
```

------------------------------------------------------------------------

# 7.4 Conversational Intake

### Purpose

Collect the user's situation through an adaptive multi-turn
conversation.

### Core Requirement

The conversation must not behave like a static questionnaire.

The backend agent determines which follow-up question is appropriate
based on the information already collected.

### UI Responsibilities

-   Display AI-generated intake messages
-   Display questions
-   Accept free-text responses
-   Display selectable options
-   Show conversation progress
-   Show typing/loading state
-   Retry failed messages
-   Preserve conversation state

### Functions

``` dart
startConversation()
sendMessage()
receiveMessage()
displayQuestion()
submitAnswer()
loadConversation()
retryMessage()
endConversation()
```

### Conversation State

``` text
conversationId
messages
currentQuestion
answers
isTyping
isSending
error
completed
```

------------------------------------------------------------------------

# 7.5 Legal Category

### Purpose

Display the likely legal category determined by the backend.

### Important Boundary

The category is an intake/routing classification, not legal advice.

### UI

``` text
Likely Intake Category
Category Description
Confidence / Status (if returned)
Continue
```

### Functions

``` dart
loadLegalCategory()
displayCategory()
continueAfterCategory()
```

------------------------------------------------------------------------

# 7.6 Urgency Triage

### Purpose

Display the urgency assessment returned by the agentic triage engine.

### Core Requirement

Urgency must be determined using the conversation context and approved
urgency definitions.

The frontend displays the result and its explanation. It does not
independently invent an urgency decision.

### UI

``` text
Urgency Level
Why this was flagged
Important facts from the user's responses
Relevant date/deadline
Next routing status
```

### Functions

``` dart
loadTriageResult()
displayUrgency()
displayUrgencyFactors()
displayTimeSensitiveInformation()
continueAfterTriage()
```

------------------------------------------------------------------------

# 8. Urgency Explanation

This is a key product requirement.

The user must be able to understand **which information they provided
caused the urgency decision**.

Example UI structure:

``` text
Why this case may require faster review

✓ You mentioned a court date.
✓ You indicated that the date is approaching.
✓ You uploaded a notice containing a relevant deadline.

These details contributed to the urgency classification.
```

The application must distinguish:

``` text
User-provided fact
        ↓
Urgency factor
        ↓
Urgency classification
```

It must not transform the explanation into legal advice.

------------------------------------------------------------------------

# 9. Agentic AI Boundary

The mobile frontend does not implement the agent's reasoning itself.

The expected flow is:

``` text
User response
     ↓
Flutter
     ↓
Backend Agent
     ↓
Conversation reasoning
     ↓
Determine next question
     ↓
Retrieve approved definitions when required
     ↓
Determine category / urgency
     ↓
Return structured result
     ↓
Flutter displays result
```

The frontend therefore needs flexible response models for:

-   next question;
-   question type;
-   category;
-   urgency;
-   urgency factors;
-   structured summary;
-   routing status.

------------------------------------------------------------------------

# 10. RAG / Approved Definitions

AidRoute uses retrieval over approved legal-category and urgency
definitions.

### Frontend responsibility

The frontend may display:

-   approved category label;
-   approved urgency label;
-   explanation returned by the backend;
-   relevant intake-definition information when the backend provides it.

### Frontend must not

-   directly query the RAG database;
-   create its own legal definitions;
-   invent category definitions;
-   invent urgency rules.

The expected architecture is:

``` text
Flutter
  ↓
Backend
  ↓
RAG
  ↓
Approved Definition
  ↓
Agent
  ↓
Structured Response
  ↓
Flutter
```

------------------------------------------------------------------------

# 11. Document Intelligence

## Purpose

Allow users to upload notices, agreements, or other supporting documents
and surface important information such as dates.

### Flow

``` text
Select Document
      ↓
Validate
      ↓
Upload
      ↓
OCR / Document Processing
      ↓
Extract Important Information
      ↓
Extract Dates
      ↓
Display Results
      ↓
User Review
```

### Frontend Responsibilities

-   File selection
-   File validation
-   Upload
-   Upload progress
-   Processing status
-   Display extracted dates
-   Display extracted information
-   Allow user review
-   Associate document with intake/case

### Functions

``` dart
selectDocument()
validateDocument()
uploadDocument()
trackProcessing()
loadAnalysis()
displayExtractedDates()
confirmDocumentInformation()
retryProcessing()
```

### Important Model

``` text
ExtractedDate
├── date
├── label
├── sourceDocument
└── context
```

The OCR/document intelligence itself belongs to the backend.

------------------------------------------------------------------------

# 12. Multilingual Intake

### Purpose

Support users with limited English proficiency.

### Frontend requirements

-   Localized interface
-   Localized validation messages
-   Language selection
-   Conversation language state
-   Unicode-safe text handling
-   Proper text direction support where required by supported languages

### Language State

``` text
selectedLanguage
availableLanguages
isLanguageLoading
```

### Functions

``` dart
loadLanguages()
selectLanguage()
changeLanguage()
saveLanguagePreference()
```

------------------------------------------------------------------------

# 13. Automated Notifications

Automated notifications are a routing-support feature.

### Possible flow

``` text
Urgent Case
     ↓
Backend Escalation
     ↓
Clinic Staff Notification
     ↓
SMS / Email
```

The mobile application may display:

``` text
Urgent review requested
Notification sent
Case routed
Staff review pending
```

### Frontend Functions

``` dart
loadEscalationStatus()
displayEscalationStatus()
refreshEscalationStatus()
```

The actual SMS/email delivery belongs to the backend.

------------------------------------------------------------------------

# 14. Lawyer Matching

### Purpose

Match a case to volunteer lawyers based on:

-   legal specialty;
-   availability.

### Flow

``` text
Case Category
     ↓
Matching Engine
     ↓
Specialty Match
     ↓
Availability
     ↓
Potential Lawyer Matches
     ↓
Mobile Display
```

### UI

``` text
Lawyer / Volunteer
Specialty
Availability
Match status
Appointment option
```

### Functions

``` dart
loadMatches()
refreshMatches()
viewLawyer()
selectLawyer()
continueToAppointment()
```

The matching algorithm belongs to the backend.

------------------------------------------------------------------------

# 15. Appointment Scheduling

### Purpose

Allow staff or users to schedule a consultation when scheduling is
enabled.

### Flow

``` text
Matched / Assigned Lawyer
       ↓
Available Dates
       ↓
Available Time Slots
       ↓
Select Slot
       ↓
Review
       ↓
Confirm Appointment
       ↓
Appointment Status
```

### Functions

``` dart
loadAvailability()
selectDate()
loadTimeSlots()
selectTimeSlot()
confirmAppointment()
cancelAppointment()
rescheduleAppointment()
loadAppointmentStatus()
```

------------------------------------------------------------------------

# 16. Eligibility Pre-Screening

### Purpose

Perform basic intake eligibility checks before routing.

### Flow

``` text
Collected Intake
      ↓
Eligibility Questions
      ↓
Basic Eligibility Check
      ↓
Eligibility Result
      ↓
Continue Routing
```

### UI

``` text
Eligibility Question
Answer
Progress
Result
Next Step
```

### Functions

``` dart
startEligibilityCheck()
submitEligibilityAnswer()
loadEligibilityResult()
continueAfterEligibility()
```

The frontend should display the eligibility result returned by the
backend rather than independently implementing policy rules.

------------------------------------------------------------------------

# 17. Structured Case Summary

The final summary should convert the conversation into an easy-to-review
structured representation.

### Suggested sections

``` text
User Information
Case Description
Key Facts
Legal Category
Urgency
Urgency Factors
Important Dates
Documents
Eligibility Status
Routing Status
Lawyer Match
Appointment
```

### Functions

``` dart
loadCaseSummary()
displayCaseSummary()
editAllowedField()
validateSummary()
confirmSummary()
```

------------------------------------------------------------------------

# 18. Proactive Escalation

A genuinely time-sensitive case should be proactively escalated.

### Flow

``` text
Conversation / Document
        ↓
Urgency Engine
        ↓
Time-Sensitive Case
        ↓
Escalation
        ↓
Clinic Staff Alert
        ↓
Routing Status
        ↓
User Confirmation
```

### Mobile UI

The application should make escalation status visible without implying
that the AI is providing legal advice.

Example:

``` text
Priority Review

Your intake contains information that has been
identified as time-sensitive.

Your case has been flagged for faster staff review.
```

### Functions

``` dart
loadEscalation()
displayEscalation()
refreshEscalationStatus()
```

------------------------------------------------------------------------

# 19. Case Submission

### Final Review

Before submission, display:

``` text
✓ User information
✓ Situation
✓ Answers
✓ Documents
✓ Category
✓ Urgency
✓ Urgency explanation
✓ Eligibility result
✓ Routing information
✓ Appointment information (if applicable)
```

### Submission Functions

``` dart
validateSubmission()
submitCase()
trackSubmission()
retrySubmission()
loadConfirmation()
```

------------------------------------------------------------------------

# 20. Data Models

## Core Models

``` text
User
Language
Intake
Question
Answer
Message
Conversation
LegalCategory
Urgency
UrgencyFactor
CaseSummary
Routing
Escalation
Submission
```

## Document Models

``` text
Document
DocumentAnalysis
ExtractedDate
```

## Optional Feature Models

``` text
Eligibility
Lawyer
LawyerMatch
Appointment
```

------------------------------------------------------------------------

# 21. Service Layer

Each service owns one domain.

  Service                       Responsibility
  ----------------------------- -------------------------------------------------
  `api_service.dart`            Common API communication
  `auth_service.dart`           Session/user authentication
  `intake_service.dart`         Intake operations
  `conversation_service.dart`   AI conversation API
  `triage_service.dart`         Category/urgency results
  `rag_service.dart`            Backend-approved definition retrieval interface
  `document_service.dart`       Upload and document results
  `eligibility_service.dart`    Eligibility checks
  `matching_service.dart`       Lawyer matching
  `appointment_service.dart`    Scheduling
  `notification_service.dart`   Escalation/notification status
  `case_service.dart`           Case and summary operations
  `submission_service.dart`     Final submission

------------------------------------------------------------------------

# 22. State Management

The application state should be separated by domain.

``` text
AppProvider
LanguageProvider
AuthProvider
IntakeProvider
ConversationProvider
TriageProvider
DocumentProvider
EligibilityProvider
MatchingProvider
AppointmentProvider
CaseProvider
SubmissionProvider
```

Each provider should expose predictable states:

``` text
initial
loading
success
empty
error
retrying
```

------------------------------------------------------------------------

# 23. Error Handling

Every asynchronous operation must support:

``` text
Idle
 ↓
Loading
 ↓
 ┌───────────────┐
 ↓               ↓
Success         Error
 ↓               ↓
Continue        Retry
```

Errors should be user-friendly.

Do not expose:

-   stack traces;
-   secret keys;
-   internal prompts;
-   internal agent reasoning;
-   database errors;
-   raw server exceptions.

------------------------------------------------------------------------

# 24. No-Legal-Advice Safeguards

This is a mandatory product constraint.

## The UI must

Use language such as:

``` text
This tool helps collect information and route your
case to legal-aid staff. It does not provide legal advice.
```

## The AI conversation must not

Generate:

``` text
"You should sue..."
"You definitely have a case..."
"The law says you must..."
"Your landlord is violating..."
"You should file..."
```

Instead, the system should remain focused on:

``` text
"What happened?"
"When did this happen?"
"Do you have a document?"
"Is there a date listed?"
"Which category best describes your situation?"
```

## Urgency explanation must be factual

``` text
You reported:
- a court date;
- an upcoming deadline.

These details contributed to the time-sensitive classification.
```

Not:

``` text
You must take legal action before this date.
```

------------------------------------------------------------------------

# 25. Accessibility

The frontend should support:

-   readable typography;
-   sufficient touch targets;
-   clear error messages;
-   screen-reader-friendly labels;
-   keyboard-safe forms;
-   accessible document upload controls;
-   clear urgency indicators that do not rely only on color;
-   simple conversational language;
-   multilingual text rendering.

------------------------------------------------------------------------

# 26. Security and Privacy

The mobile application should:

-   avoid storing sensitive information unnecessarily;
-   avoid logging user legal information;
-   avoid logging document contents;
-   protect local session information;
-   use secure API communication;
-   never contain backend service credentials;
-   never contain model-provider secret keys.

Sensitive information should be handled through the backend architecture
and appropriate authentication/authorization.

------------------------------------------------------------------------

# 27. Testing Strategy

## Unit Tests

Test:

``` text
Models
Validators
Services
Providers
State transitions
Data parsing
```

## Widget Tests

Test:

``` text
Language selection
Intake fields
Conversation messages
Question options
Urgency explanation
Document cards
Eligibility questions
Lawyer cards
Appointment slots
Case summary
Submission status
```

## Integration Tests

Test the complete flow:

``` text
Language
 → Intake
 → Conversation
 → Triage
 → Document
 → Summary
 → Eligibility
 → Routing
 → Scheduling
 → Submission
```

## Safety Tests

Explicitly test that the UI and response handling do not present legal
advice.

------------------------------------------------------------------------

# 28. Feature-to-Screen Matrix

  Feature                     Screen(s)                  Required
  --------------------------- -------------------------- ----------------
  Language Selection          Language                   Core / Bonus
  Adaptive Intake             Intake, Conversation       **Compulsory**
  Agentic Conversation        Conversation               **Compulsory**
  Legal Category              Triage                     **Compulsory**
  Urgency Triage              Triage                     **Compulsory**
  Urgency Explanation         Triage                     **Compulsory**
  RAG-backed Definitions      Triage / Conversation      **Compulsory**
  Case Summary                Case Summary               **Compulsory**
  Urgent Escalation           Triage / Confirmation      **Compulsory**
  Document Intelligence       Document Upload / Review   Bonus
  Multilingual Intake         Language / Conversation    Bonus
  Notifications               Triage / Confirmation      Bonus
  Lawyer Matching             Matching                   Bonus
  Appointment Scheduling      Appointment                Bonus
  Eligibility Pre-Screening   Eligibility                Bonus

------------------------------------------------------------------------

# 29. End-to-End User Journey

``` text
┌───────────────────────┐
│       App Start       │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│   Language Selection  │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│         Home          │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│    Start Intake       │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│ Adaptive Conversation │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│ Legal Category +      │
│ Urgency Assessment    │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│ Why Was It Flagged?   │
│ User Facts → Factors  │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│  Upload Documents     │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│ OCR / Date Extraction │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│ Eligibility Check     │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│ Lawyer Matching /     │
│ Routing               │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│ Appointment           │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│ Structured Case       │
│ Summary               │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│ Final Review          │
└───────────┬───────────┘
            ↓
┌───────────────────────┐
│ Submit Case           │
└───────────┬───────────┘
            ↓
      ┌─────┴─────┐
      ↓           ↓
   Urgent       Normal
      ↓           ↓
 Escalation     Queue
      └─────┬─────┘
            ↓
┌───────────────────────┐
│      Confirmation     │
└───────────────────────┘
```

------------------------------------------------------------------------

# 30. Implementation Order

## Phase 1 --- Foundation

-   [ ] Flutter project
-   [ ] Directory structure
-   [ ] Theme
-   [ ] Routing
-   [ ] API client
-   [ ] Common widgets
-   [ ] Error handling
-   [ ] Localization foundation

## Phase 2 --- Core Intake

-   [ ] Splash
-   [ ] Language selection
-   [ ] Home
-   [ ] Intake
-   [ ] Intake validation
-   [ ] Conversation UI
-   [ ] Adaptive question UI

## Phase 3 --- Core AI Triage

-   [ ] Conversation service
-   [ ] Conversation provider
-   [ ] Category model
-   [ ] Urgency model
-   [ ] Urgency-factor model
-   [ ] Triage screen
-   [ ] Urgency explanation

## Phase 4 --- Case Summary

-   [ ] Structured case summary
-   [ ] Summary review
-   [ ] Summary validation
-   [ ] Final review

## Phase 5 --- Document Intelligence

-   [ ] File picker
-   [ ] Upload
-   [ ] Processing state
-   [ ] OCR result
-   [ ] Important date extraction
-   [ ] Document review

## Phase 6 --- Routing Features

-   [ ] Eligibility
-   [ ] Lawyer matching
-   [ ] Availability
-   [ ] Appointment scheduling
-   [ ] Routing status

## Phase 7 --- Escalation

-   [ ] Urgent status
-   [ ] Escalation status
-   [ ] Notification status
-   [ ] Confirmation

## Phase 8 --- Testing

-   [ ] Unit tests
-   [ ] Widget tests
-   [ ] Integration tests
-   [ ] Error-state tests
-   [ ] Multilingual tests
-   [ ] No-legal-advice safety tests

------------------------------------------------------------------------

# 31. Definition of Done

## Core Product

-   [ ] User can start an intake
-   [ ] User can select a language
-   [ ] User can describe their situation conversationally
-   [ ] Conversation supports multiple turns
-   [ ] Follow-up questions are adaptive
-   [ ] Backend agent determines the next question
-   [ ] Likely legal category is returned
-   [ ] Urgency is returned
-   [ ] Urgency explanation identifies relevant user-provided
    information
-   [ ] Approved definitions are retrieved through the backend RAG
    workflow
-   [ ] Structured case summary is generated
-   [ ] Time-sensitive cases can be proactively escalated
-   [ ] User can see escalation status
-   [ ] Application never presents legal advice

## Document Intelligence

-   [ ] User can upload documents
-   [ ] Upload status is visible
-   [ ] Processing status is visible
-   [ ] OCR/extracted information can be displayed
-   [ ] Important dates can be displayed
-   [ ] User can review extracted information

## Multilingual

-   [ ] User can select supported language
-   [ ] UI is localized
-   [ ] Intake conversation can use the selected language
-   [ ] Validation/error messages support localization

## Notifications

-   [ ] Urgent case escalation status is displayed
-   [ ] Backend notification status can be displayed

## Lawyer Matching

-   [ ] Matching result can be displayed
-   [ ] Specialty can be displayed
-   [ ] Availability can be displayed

## Scheduling

-   [ ] Available dates can be displayed
-   [ ] Available time slots can be displayed
-   [ ] Appointment can be confirmed
-   [ ] Appointment status can be displayed

## Eligibility

-   [ ] Basic eligibility questions can be displayed
-   [ ] Answers can be collected
-   [ ] Eligibility result can be displayed
-   [ ] Result can affect routing

------------------------------------------------------------------------

# 32. Final Architecture

``` text
                         AIDROUTE MOBILE
                              │
                              ▼
                    ┌───────────────────┐
                    │   PRESENTATION    │
                    │                   │
                    │ Screens / Widgets │
                    └─────────┬─────────┘
                              ↓
                    ┌───────────────────┐
                    │  STATE MANAGEMENT │
                    │                   │
                    │ Intake / Chat     │
                    │ Triage / Docs     │
                    │ Case / Routing    │
                    └─────────┬─────────┘
                              ↓
                    ┌───────────────────┐
                    │     SERVICES      │
                    │                   │
                    │ Intake            │
                    │ Conversation      │
                    │ Triage            │
                    │ Documents         │
                    │ Eligibility       │
                    │ Matching          │
                    │ Scheduling        │
                    │ Submission        │
                    └─────────┬─────────┘
                              ↓
                    ┌───────────────────┐
                    │    API CLIENT     │
                    └─────────┬─────────┘
                              ↓
                    ┌───────────────────┐
                    │    BACKEND API    │
                    │                   │
                    │ Agentic AI        │
                    │ RAG               │
                    │ Triage            │
                    │ OCR               │
                    │ Routing           │
                    │ Notifications     │
                    │ Matching          │
                    │ Scheduling        │
                    └───────────────────┘
```

------------------------------------------------------------------------

# 33. Product Principle

The most important principle for every frontend feature is:

> **AidRoute helps the user explain their situation and helps legal-aid
> organizations prioritize and route the case. It does not replace a
> lawyer and does not provide legal advice.**

Every screen, API response, model, notification, and AI-generated
message shown in the mobile application must respect this boundary.
