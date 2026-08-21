# Placeholder domain model for a Document

class Document:
    def __init__(self, doc_id: str, metadata: dict):
        self.doc_id = doc_id
        self.metadata = metadata
