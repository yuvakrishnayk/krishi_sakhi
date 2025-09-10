import os
from dotenv import load_dotenv

#Loaded environment variables from a .env file
load_dotenv()

#Pinecone Settings
PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
INDEX_NAME = "agri-rag-index"
NAMESPACE = "__default__"
EMBEDDING_MODEL = "llama-text-embed-v2"
PDF_PATH = "resources/resources.pdf"


