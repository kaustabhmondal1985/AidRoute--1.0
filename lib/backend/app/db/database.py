# Placeholder database abstraction
"""
This module provides a minimal interface for the Supabase PostgreSQL connection.
Actual connection details will be configured later when the schema is finalized.
"""

class Database:
    """A stub for the database connection.
    Future implementation will create an async Supabase client or SQLAlchemy engine.
    """
    def __init__(self, dsn: str = ""):
        self.dsn = dsn

    async def connect(self):
        """Simulate an async connection method."""
        pass

    async def disconnect(self):
        """Simulate an async disconnect method."""
        pass
