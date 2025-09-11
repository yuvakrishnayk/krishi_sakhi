from typing import List, Tuple, Any, Dict
from pinecone import Pinecone
from config.settings import PINECONE_API_KEY, EMBEDDING_MODEL

def init_pinecone_and_index(index_name: str) -> Tuple[Any, Any]:
    """
    Initialize Pinecone client and return the specified index.
    Uses the newer Pinecone SDK pattern.
    """
    # Initialize Pinecone client
    pc = Pinecone(api_key=PINECONE_API_KEY)
    
    # List existing indexes
    indexes = pc.list_indexes()
    index_exists = index_name in [idx.name for idx in indexes.indexes]
    
    if not index_exists:
        print(f"Creating new index: {index_name}")
        # Create the index - adjust dimension to match your embedding model
        try:
            # Try ServerlessSpec first (newer approach)
            from pinecone import ServerlessSpec
            pc.create_index(
                name=index_name,
                dimension=1024,  # Adjust based on your embedding model
                metric="cosine",
                spec=ServerlessSpec(
                    cloud='aws',
                    region='us-west-2'  # Choose appropriate region
                )
            )
        except ImportError:
            # Fall back to older approach if ServerlessSpec not available
            pc.create_index(
                name=index_name,
                dimension=1024,
                metric="cosine"
            )
    else:
        print(f"Index '{index_name}' exists, describing index...")

    # Get index information and connect to it
    index_info = pc.describe_index(name=index_name)
    index = pc.Index(host=index_info.host)
    
    return pc, index


def upsert_docs(index, docs: List, namespace: str = "__default__", batch_size: int = 96) -> None:
    """
    Insert document chunks into Pinecone index.
    Updated for the newer Pinecone SDK.
    """
    records = []
    for i, doc in enumerate(docs):
        # Format for newer Pinecone SDK
        rec = {
            "id": f"doc_{i}",
            "values": [],  # Will be filled by embedding model
            "metadata": {
                "chunk_text": doc.page_content,
                "page": doc.metadata.get("page", i),
            }
        }
        records.append(rec)

    # Batch upsert
    total_batches = (len(records) + batch_size - 1) // batch_size
    for i in range(0, len(records), batch_size):
        batch = records[i:i + batch_size]
        current_batch = i // batch_size + 1
        print(f"Upserting batch {current_batch}/{total_batches} ({len(batch)} records)")
        
        try:
            # Try the newer upsert method first
            if hasattr(index, 'upsert_records'):
                transformed_batch = [{
                    "_id": rec["id"],
                    "chunk_text": rec["metadata"]["chunk_text"],
                    "page": rec["metadata"]["page"]
                } for rec in batch]
                index.upsert_records(namespace=namespace, records=transformed_batch)
            else:
                # Fall back to older upsert method
                index.upsert(vectors=batch, namespace=namespace)
        except Exception as e:
            print(f"Error in batch {current_batch}: {e}")
            import traceback
            traceback.print_exc()
            # Try with default format if custom format fails
            try:
                index.upsert(vectors=batch, namespace=namespace)
            except Exception as e2:
                print(f"Second attempt failed: {e2}")
                raise

