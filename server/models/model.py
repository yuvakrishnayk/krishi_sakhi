from pydantic import BaseModel
from typing import List, Optional

class QueryRequest(BaseModel):
    query: str
    top_k: int = 5
    show_thinking: bool = False

class QueryResponse(BaseModel):
    answer: str
    reasoning: Optional[str] = None
    context_chunks: Optional[List[str]] = None
