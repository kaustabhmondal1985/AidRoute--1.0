import os
import sys

# Ensure the project root is in PYTHONPATH so we can import the backend package
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

# Import the FastAPI app defined in backend/app/main.py
from lib.backend.app.main import app

