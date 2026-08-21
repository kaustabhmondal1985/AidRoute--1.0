# Placeholder document repository
"""
Repository layer for Document domain objects.
"""

class DocumentRepository:
    def __init__(self, db):
        self.db = db

    async def get_document(self, doc_id: str):
        pass

    async def create_document(self, doc_data):
        pass
