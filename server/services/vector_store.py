"""
FAISS 向量数据库服务
负责文档向量化存储和相似检索

注：原方案使用 ChromaDB，但在本机 Windows 环境下 chromadb 的 C++/Rust 原生层
（chroma-hnswlib）会稳定触发段错误（Segmentation fault），故改用 FAISS。
"""
from typing import List, Optional
import os
import pickle

import numpy as np
import faiss

from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_core.documents import Document

from config import (
    EMBEDDING_API_KEY,
    EMBEDDING_BASE_URL,
    EMBEDDING_MODEL,
    EMBEDDING_DIMENSIONS,
    VECTOR_DIR,
    CHUNK_SIZE,
    CHUNK_OVERLAP,
    RAG_TOP_K,
)


class VectorStoreService:
    """FAISS向量数据库服务类"""

    def __init__(self):
        """初始化嵌入模型和向量存储"""
        self.embeddings = OpenAIEmbeddings(
            model=EMBEDDING_MODEL,
            api_key=EMBEDDING_API_KEY,
            base_url=EMBEDDING_BASE_URL,
            dimensions=EMBEDDING_DIMENSIONS,
            # 阿里云兼容接口只接受 str / list[str]，LangChain 默认会发送 token id 数组导致 400
            check_embedding_ctx_length=False,
        )
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=CHUNK_SIZE,
            chunk_overlap=CHUNK_OVERLAP,
            length_function=len,
        )
        self._vectorstore: Optional[FAISS] = None

    def _save(self, store: FAISS) -> None:
        """
        持久化 FAISS 索引。
        不用 langchain 自带的 save_local，因为其内部 faiss.write_index 走 C++ fopen，
        在本机项目路径含全角括号「（」时无法打开文件；这里改用 serialize_index +
        Python 字节读写，可正确处理非 ASCII 路径。
        """
        VECTOR_DIR.mkdir(parents=True, exist_ok=True)
        # index 单独序列化（不可 pickle）
        data = faiss.serialize_index(store.index)  # numpy uint8 数组
        (VECTOR_DIR / "index.faiss").write_bytes(data.tobytes())
        # docstore + index_to_docstore_id 走 pickle
        with open(VECTOR_DIR / "index.pkl", "wb") as f:
            pickle.dump((store.docstore, store.index_to_docstore_id), f)

    def _load(self) -> Optional[FAISS]:
        """若本地索引文件存在则加载，否则返回 None（表示尚未建库）"""
        faiss_path = VECTOR_DIR / "index.faiss"
        pkl_path = VECTOR_DIR / "index.pkl"
        if not faiss_path.exists() or not pkl_path.exists():
            return None

        index = faiss.deserialize_index(
            np.frombuffer(faiss_path.read_bytes(), dtype=np.uint8).copy()
        )
        with open(pkl_path, "rb") as f:
            docstore, index_to_docstore_id = pickle.load(f)
        return FAISS(self.embeddings, index, docstore, index_to_docstore_id)

    @property
    def vectorstore(self) -> Optional[FAISS]:
        """懒加载 FAISS 实例（可能为 None）"""
        if self._vectorstore is None:
            self._vectorstore = self._load()
        return self._vectorstore

    def add_documents(self, text: str, file_id: int, file_name: str) -> int:
        """
        将文本分块并向量化存入 FAISS
        :param text: 文档文本内容
        :param file_id: 知识库文件ID
        :param file_name: 文件名
        :return: 分块数量
        """
        doc = Document(
            page_content=text,
            metadata={"file_id": file_id, "file_name": file_name},
        )
        chunks = self.text_splitter.split_documents([doc])
        if not chunks:
            return 0

        store = self.vectorstore
        if store is None:
            store = FAISS.from_documents(chunks, self.embeddings)
        else:
            store.add_documents(chunks)
        self._save(store)
        self._vectorstore = store
        return len(chunks)

    def delete_by_file_id(self, file_id: int) -> None:
        """
        根据文件ID删除向量数据
        注：FAISS 不支持按 metadata 过滤删除，这里通过遍历 docstore 找到
        对应 file_id 的文档 id 后调用 delete() 重建索引。
        :param file_id: 知识库文件ID
        """
        try:
            store = self.vectorstore
            if store is None:
                return
            ids_to_delete = [
                docstore_id
                for docstore_id, doc in store.docstore._dict.items()
                if str(doc.metadata.get("file_id")) == str(file_id)
            ]
            if ids_to_delete:
                store.delete(ids_to_delete)
                self._save(store)
        except Exception:
            pass

    def similarity_search(self, query: str, top_k: int = RAG_TOP_K) -> List[Document]:
        """
        相似度检索
        :param query: 查询文本
        :param top_k: 返回Top-K结果
        :return: 相关文档列表
        """
        try:
            store = self.vectorstore
            if store is None:
                return []
            return store.similarity_search(query, k=top_k)
        except Exception:
            return []


# 全局单例
vector_store_service = VectorStoreService()
