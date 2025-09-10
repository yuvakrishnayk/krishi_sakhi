from typing import Any, Dict, List, Optional, Union

def search(
    index: Any,
    query_text: Optional[str] = None,
    top_k: int = 10,
    namespace: str = "__default__",
    rerank: bool = False,
    fields: Optional[List[str]] = None,
    query_vector: Optional[List[float]] = None,
    query_id: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Pinecone search using the current SDK:
      - If query_text is provided: uses integrated text search (requires index created for model).
      - Else if query_vector is provided: searches by vector.
      - Else if query_id is provided: searches by record ID.
    Optional: rerank with hosted model.
    Returns the index.search(...) response dict.
    """
    if fields is None:
        fields = ["chunk_text"]  # include the text field used for rerank and display [1][5]

    # Build the query payload
    query: Dict[str, Any] = {"top_k": top_k}

    if query_text:
        # Integrated-embedding path: server embeds the text (requires create_index_for_model) [1]
        query["inputs"] = {"text": query_text}  # [1]
    elif query_vector is not None:
        query["vector"] = {"values": query_vector}  # must match index dimension [19]
    elif query_id:
        query["id"] = query_id  # search by record id [1]
    else:
        raise ValueError("Provide one of query_text, query_vector, or query_id")  # [1]

    # Optional rerank payload
    rerank_payload: Optional[Dict[str, Any]] = None
    if rerank:
        # rank_fields must be included in 'fields' as per docs [1][5]
        rerank_payload = {
            "model": "bge-reranker-v2-m3",
            "top_n": min(top_k, 10),  # keep top_n reasonable; adjust as needed [5]
            "rank_fields": ["chunk_text"],
        }

    # Execute search
    if rerank_payload:
        result = index.search(
            namespace=namespace,
            query=query,
            fields=fields,
            rerank=rerank_payload,
        )  # returns dict with result.hits and fields/_score [1][5]
    else:
        result = index.search(
            namespace=namespace,
            query=query,
            fields=fields,
        )  # [1]

    return result  # access hits via result["result"]["hits"] [1]
