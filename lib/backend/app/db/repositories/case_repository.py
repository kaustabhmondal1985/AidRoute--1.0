# Placeholder case repository
"""
Repository layer for Case domain objects.
Will later implement CRUD operations against Supabase.
"""

class CaseRepository:
    def __init__(self, db):
        self.db = db

    async def get_case(self, case_id: str):
        pass

    async def create_case(self, case_data):
        pass
