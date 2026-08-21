# AidRoute Backend

## Project Overview

AidRoute is a multilingual legal‑aid intake and triage platform. This repository contains the **backend foundation** built with FastAPI, prepared for future integration of AI agents, RAG, and a Supabase PostgreSQL database.

## Getting Started

1. **Clone the repository** and navigate to the `backend` folder.
2. **Create a virtual environment** (Windows example):
   ```powershell
   python -m venv .venv
   .\.venv\Scripts\activate
   ```
3. **Install dependencies**:
   ```powershell
   pip install -r requirements.txt
   ```
4. **Create a `.env` file** based on `.env.example` and fill in your secrets:
   ```text
   GEMINI_API_KEY=your_gemini_key
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_anon_key
   ```
5. **Run the development server**:
   ```powershell
   uvicorn app.main:app --reload
   ```
6. Open your browser at `http://127.0.0.1:8000/api/health` – you should see:
   ```json
   {"status": "ok"}
   ```

## Folder Structure

```
backend/
│
├─ app/
│   ├─ main.py                # FastAPI entry point
│   ├─ config/                # Settings & constants
│   ├─ api/                    # Routers & endpoint definitions
│   │   ├─ router.py
│   │   └─ routes/            # Individual route modules (health, intake, …)
│   ├─ agents/                # Placeholder AI agent classes
│   ├─ graph/                 # LangGraph state/workflow placeholders
│   ├─ rag/                   # RAG pipeline stubs
│   ├─ ai/                    # Gemini client stub
│   ├─ documents/             # Document processing stubs
│   ├─ models/                # Domain model placeholders
│   ├─ schemas/               # Pydantic request/response schemas
│   ├─ services/              # Business‑logic service stubs
│   └─ db/                    # Database abstraction & repositories
│
├─ knowledge/                # Markdown knowledge base (empty placeholders)
├─ scripts/                  # Utility scripts (e.g., ingest_knowledge.py)
├─ tests/                    # Test suite
│   ├─ test_api.py           # Health endpoint test
│   ├─ test_rag.py           # Placeholder
│   ├─ test_agents.py        # Placeholder
│   └─ test_documents.py     # Placeholder
│
├─ .env.example              # Template env file
├─ .gitignore                # Standard Python ignores
├─ requirements.txt           # Minimal dependencies
└─ README.md                 # This file
```

## Next Steps

- Implement RAG pipeline inside `app/rag/`.
- Flesh out LangGraph workflows in `app/graph/`.
- Build concrete AI agents in `app/agents/`.
- Add database models and repository logic under `app/db/`.
- Expand API routes and services as business logic is defined.

---

*This README focuses on the current foundation. Future documentation will cover detailed AI, RAG, and database integration.*

# ⚖️ AidRoute 1.0 - Multi-Agent Legal-Aid Intake & Triage Platform (Backend)

[![FastAPI](https://img.shields.io/badge/FastAPI-0.110.0-009688.svg?style=flat&logo=FastAPI)](https://fastapi.tiangolo.com/)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB.svg?style=flat&logo=Python)](https://www.python.org/)
[![LangGraph](https://img.shields.io/badge/LangGraph-Multi--Agent_Workflow-ff69b4.svg)](https://python.langchain.com/docs/langgraph)
[![Groq](https://img.shields.io/badge/Groq-LLaMA3_Inference-f34f29.svg)](https://groq.com/)
[![Google Gemini](https://img.shields.io/badge/Google_Gemini-AI_Engine-4285F4.svg)](https://ai.google.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL_%26_Vector-3ECF8E.svg)](https://supabase.com/)

**AidRoute** is an AI-powered legal-aid intake, triage, and pro-bono matching backend platform. Designed to assist legal clinics and underserved individuals, AidRoute automates case intake conversations in multiple languages (including Hinglish), classifies legal issues, assesses urgency, retrieves relevant legal information via RAG (Retrieval-Augmented Generation), matches pro-bono lawyers by specialization and geography, and coordinates consultation appointments.

---

## 🌟 Key Features

* **🤖 LangGraph Multi-Agent Orchestration**: Stateful DAG execution graph (`CaseState`) that coordinates specialized AI agents dynamically based on case progress and user responses.
* **💬 Dynamic Conversational Intake (`IntakeAgent`)**: Conducts natural, empathetic intake conversations. Understood in Hinglish, English, and regional nuances; dynamically formulates single follow-up questions without fixed static scripts, respecting document evidence and context.
* **🏷️ Automated Case Classification (`CaseAgent`)**: Identifies case categories (Housing/Eviction, Employment Termination, Family Dispute, Consumer Rights, Criminal Defense) with confidence scores and reasoning.
* **🚨 Urgency Assessment & Triage (`UrgencyAgent`)**: Triages legal emergency levels (`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`) based on impending court dates, illegal lockouts, or safety risks.
* **📚 RAG Legal Knowledge Retrieval (`LegalInfoAgent` & Retriever)**: Leverages vector similarity search over embedded legal aid guidelines (including NALSA eligibility standards) to synthesize non-advisory legal summaries with citations.
* **👨‍⚖️ Pro-Bono Lawyer Matching**: Filters and ranks available pro-bono attorneys by category, city, experience, and current availability.
* **📅 Appointment Booking Engine**: Real-time slot query, consultation booking, status tracking, and cancellation system.
* **🛡️ Ethical Guardrails & Escalation**: Strict non-advisory boundary enforcement with automated human review triggers (`human_review_node`) for edge cases or severe urgency.

---

## 🏗️ System Architecture & Workflow

```
                          [ User Message / Document Upload ]
                                         │
                                         ▼
                                ( START / Router )
                                         │
                   ┌─────────────────────┴─────────────────────┐
                   ▼                                           ▼
          [ classify_case ]                            [ intake_node ]
         (Case Category ID)                   (Dynamic Follow-up Question)
                   │                                           │
                   └─────────────────────┬─────────────────────┘
                                         ▼
                                 [ urgency_node ]
                             (Emergency Level Triage)
                                         │
                                         ▼
                                   [ rag_node ]
                           (Vector Search Knowledge)
                                         │
                                         ▼
                               [ legal_info_node ]
                           (Synthesize Information)
                                         │
                                         ▼
                            [ lawyer_matching_node ]
                          (Filter & Rank Attorneys)
                                         │
                                         ▼
                              [ human_review_node ]
                            (Safety & Escalation Check)
                                         │
                                         ▼
                             [ finalize_case_node ]
                                         │
                                         ▼
                                      ( END )
```

---

## 📁 Repository Directory Structure

```
AidRoute--1.0-backend/
├── app/
│   └── main.py                     # Root FastAPI entrypoint wrapper
└── backend/
    ├── app/
    │   ├── main.py                 # Core FastAPI application initialization
    │   ├── agents/                 # Specialized AI Agent modules
    │   │   ├── intake_agent.py     # Conversational intake agent (Groq / LLaMA-3)
    │   │   ├── case_agent.py       # Case classification agent
    │   │   ├── urgency_agent.py    # Urgency & emergency triage agent
    │   │   ├── legal_info_agent.py # RAG synthesis agent
    │   │   └── document_agent.py   # Document text & fact extraction agent
    │   ├── ai/                     # LLM Provider Clients (Groq, Gemini, Prompts)
    │   ├── api/                    # REST API Routes & Routers
    │   │   ├── router.py           # Unified API Router (/api)
    │   │   ├── lawyers.py          # Pro-bono lawyer matching endpoints
    │   │   ├── appointments.py     # Appointment booking & slot endpoints
    │   │   └── routes/
    │   │       ├── health.py       # Health checks
    │   │       ├── intake.py       # Conversational intake endpoints
    │   │       ├── documents.py    # Document upload & OCR endpoints
    │   │       └── cases.py        # Case analysis orchestrator endpoint
    │   ├── appointments/           # Appointment service logic & Pydantic models
    │   ├── config/                 # Pydantic Settings & system constants
    │   ├── db/                     # Supabase DB connection & repositories
    │   ├── documents/              # Document parser & text extractors
    │   ├── graph/                  # LangGraph DAG state machine & nodes
    │   ├── lawyers/                # Lawyer matching algorithm & data models
    │   ├── models/                 # Domain data models (Case, Message, Assessment)
    │   ├── rag/                    # Vector chunker, embeddings, & retriever
    │   ├── schemas/                # API Request / Response Pydantic schemas
    │   └── services/               # Orchestration and business logic services
    ├── knowledge/                  # Legal Knowledge Base Markdown Files
    │   ├── disclaimers/            # System rules & disclaimers
    │   ├── legal_aid/              # Intake & NALSA eligibility guidelines
    │   ├── legal_categories/       # Category guides (Housing, Family, Employment, etc.)
    │   └── urgency/                # Urgency definition rules
    ├── scripts/                    # Test scripts & Knowledge Ingestion CLI
    │   ├── ingest_knowledge.py     # Ingest & embed knowledge base files
    │   ├── test_workflow.py        # Test full LangGraph workflow
    │   ├── test_case_orchestrator.py # Test case analysis pipeline
    │   ├── test_lawyer_matching.py # Test lawyer matching algorithms
    │   └── test_appointments.py    # Test appointment booking service
    ├── tests/                      # API unit test suite
    ├── .env.example                # Environment variables template
    ├── requirements.txt            # Python dependencies
    └── README.md                   # Backend documentation
```

---

## ⚡ Quick Start & Installation

### 1. Prerequisites
* Python 3.10 or higher
* Groq API Key (for fast agent inference)
* Google Gemini API Key (optional fallback / multi-modal)
* Supabase Account & Database (for Vector Store & persistent state)

### 2. Setup Virtual Environment
```powershell
# Clone or navigate to the repository folder
cd AidRoute--1.0-backend

# Create virtual environment
python -m venv .venv

# Activate virtual environment (Windows PowerShell)
.\.venv\Scripts\activate

# Activate virtual environment (Linux / macOS)
source .venv/bin/activate
```

### 3. Install Dependencies
```bash
pip install -r backend/requirements.txt
```

### 4. Configure Environment Variables
Copy `.env.example` to `.env` inside the `backend` folder (or root) and add your API credentials:

```ini
# backend/.env
GROQ_API_KEY=your_groq_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_supabase_anon_or_service_key
```

### 5. Ingest Legal Knowledge Base (RAG Setup)
Populate the vector database with NALSA guidelines and category knowledge:
```powershell
python -m backend.scripts.ingest_knowledge
```

### 6. Run the FastAPI Development Server
```powershell
uvicorn app.main:app --reload --port 8000
```
* Interactive API Documentation (Swagger UI): `http://127.0.0.1:8000/docs`
* ReDoc UI: `http://127.0.0.1:8000/redoc`
* Health Endpoint: `http://127.0.0.1:8000/api/health`

---

## 🔌 Core API Endpoints Reference

### 1. Health Status
* **GET** `/api/health`
  * **Response**: `{"status": "ok", "service": "AidRoute Backend"}`

### 2. Case Orchestration & Analysis
* **POST** `/api/cases/analyze`
  * **Request Payload**:
    ```json
    {
      "user_message": "My landlord locked me out of my apartment without notice today in Mumbai.",
      "category": "HOUSING_EVICTION",
      "city": "Mumbai",
      "max_lawyers": 3,
      "max_chunks": 5
    }
    ```
  * **Response**: Unified json object containing category confidence, reasoning, RAG knowledge chunks, and matched pro-bono lawyers.

### 3. Pro-Bono Lawyer Matching
* **GET** `/api/lawyers/match?category=HOUSING_EVICTION&city=Mumbai&limit=5`
  * **Response**: Filtered list of verified pro-bono attorneys matching domain and location parameters.

### 4. Appointment Booking Engine
* **GET** `/api/appointments/slots?lawyer_id=LAW-101&date=2026-08-25T00:00:00Z`
  * **Response**: Array of available UTC datetime slots.
* **POST** `/api/appointments`
  * **Request Payload**:
    ```json
    {
      "case_id": "CASE-9842",
      "lawyer_id": "LAW-101",
      "user_name": "Rahul Sharma",
      "user_phone": "+919876543210",
      "appointment_time": "2026-08-25T10:00:00Z"
    }
    ```
  * **Response**: Booking confirmation object with unique `appointment_id` and status `SCHEDULED`.
* **POST** `/api/appointments/{appointment_id}/cancel`
  * **Response**: Updated appointment object with status `CANCELLED`.

---

## 🧪 Testing & Verification Scripts

Run the built-in automated test scripts to verify backend capabilities:

```powershell
# 1. Test full multi-agent LangGraph workflow engine
python -m backend.scripts.test_workflow

# 2. Test case classification, RAG retrieval & lawyer orchestrator
python -m backend.scripts.test_case_orchestrator

# 3. Test lawyer matching algorithm
python -m backend.scripts.test_lawyer_matching

# 4. Test appointment slot generation & booking workflow
python -m backend.scripts.test_appointments

# 5. Run pytest unit tests
pytest backend/tests/
```

---

## 🛡️ Safety, Ethics & Disclaimers

> **IMPORTANT DISCLAIMER**
> AidRoute is designed purely as an **administrative intake, triage, and informational assistance tool** for legal clinics and pro-bono networks.
> * AidRoute is **NOT** a lawyer and does **NOT** provide binding legal advice or establish an attorney-client relationship.
> * All syntheses generated by `LegalInfoAgent` are strictly informational and reference non-advisory legal aid resources (e.g. NALSA).
> * High urgency cases or complex legal disputes are flagged for mandatory human legal review (`requires_human_review: true`).

---

## 📄 License

This repository is maintained for AidRoute Legal-Aid Initiatives. Distributed under the MIT License.
