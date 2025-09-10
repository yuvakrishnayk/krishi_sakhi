# app.py
from config.settings import INDEX_NAME, NAMESPACE
from utils.pinecone_client import init_pinecone_and_index
from rag.search_engine import search
from groq import Groq
from dotenv import load_dotenv

load_dotenv()

GROQ_MODEL = "openai/gpt-oss-20b"  # Groq model id  # [7]

def answer_with_groq(context_chunks, question, show_thinking=True):
    client = Groq()
    context = "\n\n".join(context_chunks)
    prompt = (
        "Use the provided context to answer concisely.\n\n"
        f"Context:\n{context}\n\nQuestion: {question}\nAnswer:"
    )

    params = {
        "model": GROQ_MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.2,
    }

    # GPT‑OSS 20B does not support reasoning_format='raw'; use 'parsed' to expose thinking separately
    if show_thinking:
        params["reasoning_format"] = "parsed"   # 'raw' is not supported for this model  # [21]
        params["reasoning_effort"] = "medium"   # 'low' | 'medium' | 'high' supported on GPT‑OSS  # [21][22]

    completion = client.chat.completions.create(**params)

    # choices is a list; take the first choice
    msg = completion.choices[0].message  # [52]

    # In parsed mode, Groq exposes reasoning separately; handle both possible attributes
    reasoning = getattr(msg, "reasoning", None) or getattr(msg, "reasoning_content", None)  # [21]

    content = (msg.content or "").strip()
    return content, reasoning  # [21][52]


def main():
    print("Starting Agricultural RAG System")  # [9]
    pc, index = init_pinecone_and_index(INDEX_NAME)  # ensure integrated text index  # [12]

    print("Running example query...")  # [9]
    query = "Author name of the book is?"  # [9]
    # Pinecone integrated text search: accepts raw text query and returns fields per record
    res = search(index, query_text=query, top_k=5, namespace=NAMESPACE, rerank=True)  # [12][9]

    result = res.get("result", {})
    hits = result.get("hits", [])
    if not hits:
        print("No hits found")
        return  # [12]

    # Collect top chunk texts for the LLM
    contexts = []
    for hit in hits:
        fields = hit.get("fields", {})  # Pinecone integrated search returns fields per hit
        text = fields.get("chunk_text", "") or ""
        contexts.append(text)  # [12][9]

    # Show parsed thinking and the final answer
    content, reasoning = answer_with_groq(contexts, query, show_thinking=True)  # [21]
    if reasoning:
        print("\nThinking:\n")
        print(reasoning)  # parsed reasoning block  # [21]

    print("\nAnswer:\n")
    print(content)  # [52]


if __name__ == "__main__":
    main()
