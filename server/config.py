
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    DATABASE_URL: str = "mysql+pymysql://root:123456@127.0.0.1:3306/db_ai_shop?charset=utf8mb4"
    SECRET_KEY: str = "ai-shop-secret-key-2026-langchain-rag"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_HOURS: int = 24
    UPLOAD_DIR: str = "填写上传目录路径"
    # ── DeepSeek 对话模型 ──
    DEEPSEEK_API_KEY: str = ""
    DEEPSEEK_BASE_URL: str = "https://api.deepseek.com"
    CHAT_MODEL: str = "deepseek-chat"

    # ── 阿里云 Embedding（保持不变）──
    EMBEDDING_API_KEY: str = ""
    EMBEDDING_BASE_URL: str = "https://dashscope.aliyuncs.com/compatible-mode/v1"
    EMBEDDING_MODEL: str = "text-embedding-v4"
    EMBEDDING_DIMENSIONS: int = 2048
    RAG_TOP_K: int = 4
    CHUNK_SIZE: int = 500
    CHUNK_OVERLAP: int = 50
    PROJECT_NAME: str = "基于LangChain的带AI智能客服的微信小程序农产品商城系统"


settings = Settings()

BASE_DIR = Path(__file__).resolve().parent

DATABASE_URL = settings.DATABASE_URL
SECRET_KEY = settings.SECRET_KEY
ALGORITHM = settings.ALGORITHM
ACCESS_TOKEN_EXPIRE_HOURS = settings.ACCESS_TOKEN_EXPIRE_HOURS
UPLOAD_DIR = Path(settings.UPLOAD_DIR)
DEEPSEEK_API_KEY = settings.DEEPSEEK_API_KEY
DEEPSEEK_BASE_URL = settings.DEEPSEEK_BASE_URL
CHAT_MODEL = settings.CHAT_MODEL
EMBEDDING_API_KEY = settings.EMBEDDING_API_KEY
EMBEDDING_BASE_URL = settings.EMBEDDING_BASE_URL
EMBEDDING_MODEL = settings.EMBEDDING_MODEL
EMBEDDING_DIMENSIONS = settings.EMBEDDING_DIMENSIONS
RAG_TOP_K = settings.RAG_TOP_K
CHUNK_SIZE = settings.CHUNK_SIZE
CHUNK_OVERLAP = settings.CHUNK_OVERLAP
PROJECT_NAME = settings.PROJECT_NAME

KNOWLEDGE_DIR = UPLOAD_DIR / "knowledge"
PRODUCT_DIR = UPLOAD_DIR / "product"
BANNER_DIR = UPLOAD_DIR / "banner"
AVATAR_DIR = UPLOAD_DIR / "avatar"
VECTOR_DIR = BASE_DIR / "vector_store"


def init_dirs():
    UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
    KNOWLEDGE_DIR.mkdir(parents=True, exist_ok=True)
    PRODUCT_DIR.mkdir(parents=True, exist_ok=True)
    BANNER_DIR.mkdir(parents=True, exist_ok=True)
    AVATAR_DIR.mkdir(parents=True, exist_ok=True)
    VECTOR_DIR.mkdir(parents=True, exist_ok=True)