import sys

# Ensure the project root is on the path for imports when run as a module
if __name__ == "__main__":
    # Adjust sys.path to include the directory containing the 'backend' package
    import os
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
    if project_root not in sys.path:
        sys.path.insert(0, project_root)

    from lib.backend.app.rag.ingestion import ingest_knowledge_base

    result = ingest_knowledge_base()
    print("Knowledge ingestion summary:")
    for key, value in result.items():
        print(f"{key}: {value}")
