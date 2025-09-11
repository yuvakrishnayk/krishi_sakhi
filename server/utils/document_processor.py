from typing import List
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.document_loaders import PyPDFLoader


def load_and_chunk(pdf_path: str, chunk_size: int = 1000, chunk_overlap: int = 200) -> List:
    """
    Load a PDF document and split it into chunks.
    """
    loader = PyPDFLoader(pdf_path)
    docs = loader.load()
    splitter = RecursiveCharacterTextSplitter(chunk_size=chunk_size, chunk_overlap=chunk_overlap)
    return splitter.split_documents(docs)

