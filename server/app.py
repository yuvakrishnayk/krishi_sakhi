from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Body, Request
from models.model import QueryRequest, QueryResponse
from config.settings import INDEX_NAME, NAMESPACE
from utils.pinecone_client import init_pinecone_and_index
from rag.search_engine import search
from rag.rag import answer_with_groq
import uvicorn

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: init Pinecone once
    pc, index = init_pinecone_and_index(INDEX_NAME)
    app.state.pc = pc
    app.state.index = index
    print("Pinecone client initialized.")
    yield
    # Shutdown: cleanup if applicable
    # e.g., await app.state.pc.close() if the client supports it
    app.state.pc = None
    app.state.index = None

app = FastAPI(
    title="Agricultural RAG API",
    description="A Retrieval-Augmented Generation (RAG) API for agricultural data using FastAPI, Pinecone, and Groq.",
    version="1.0.0",
    lifespan=lifespan,  # use lifespan instead of on_event
)

@app.get("/health")
async def health_check(request: Request):
    if getattr(request.app.state, "index", None) is None:
        raise HTTPException(status_code=503, detail="Pinecone index not initialized.")
    return {"status": "healthy"}

@app.post("/query", response_model=QueryResponse)
async def query_documents(request_body: QueryRequest = Body(...), request: Request = None):
    index = getattr(request.app.state, "index", None)
    if index is None:
        raise HTTPException(status_code=503, detail="Pinecone index not initialized.")

    res = search(
        index=index,
        query_text=request_body.query,
        top_k=request_body.top_k,
        namespace=NAMESPACE,
        rerank=True,
    )

    # Fix: Use "result" (singular) instead of "results"
    result = res.get("result", {})
    hits = result.get("hits", [])
    if not hits:
        return QueryResponse(
            answer="No relevant documents found.",
            reasoning=None,
            context_chunks=[],
        )

    contexts = []
    for hit in hits:
        fields = hit.get("fields", {}) or {}
        text = fields.get("chunk_text", "") or ""
        contexts.append(text)

    content, reasoning = answer_with_groq(
        contexts,
        request_body.query,
        show_thinking=request_body.show_thinking,
    )

    return QueryResponse(
        answer=content,
        reasoning=reasoning if request_body.show_thinking else None,
        context_chunks=contexts if request_body.show_thinking else None,
    )

if __name__ == "__main__":
    uvicorn.run("app:app", host="0.0.0.0", port=8000, reload=True)
