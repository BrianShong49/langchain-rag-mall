"""
AI智能客服服务
基于LangChain RAG实现知识增强问答
"""
import uuid
from typing import List, Optional

from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage
from sqlalchemy.orm import Session

from config import DEEPSEEK_API_KEY, DEEPSEEK_BASE_URL, CHAT_MODEL, RAG_TOP_K
from models.chat import ChatMessage
from services.vector_store import vector_store_service


class AIService:
    """AI智能客服服务类"""

    def __init__(self):
        """初始化大语言模型"""
        self.llm = ChatOpenAI(
            model=CHAT_MODEL,
            api_key=DEEPSEEK_API_KEY,
            base_url=DEEPSEEK_BASE_URL,
            temperature=0.7,
        )

    def _build_rag_prompt(self, question: str, context_docs: List) -> str:
        """
        构建RAG增强提示词
        :param question: 用户问题
        :param context_docs: 检索到的上下文文档
        :return: 完整提示词
        """
        context = "\n\n".join([doc.page_content for doc in context_docs])
        if not context:
            context = "暂无相关知识库内容。"

        return f"""你是「基于LangChain的带AI智能客服的微信小程序商城系统」的智能客服助手。
请根据以下知识库内容回答用户问题。如果知识库中没有相关信息，请基于商城常识礼貌回答，并建议用户联系人工客服。

【知识库参考内容】
{context}

【用户问题】
{question}

请用简洁、友好的中文回答。"""

    def chat(
        self,
        db: Session,
        user_id: int,
        message: str,
        session_id: Optional[str] = None,
    ) -> dict:
        """
        处理用户聊天请求(RAG增强)
        :param db: 数据库会话
        :param user_id: 用户ID
        :param message: 用户消息
        :param session_id: 会话ID
        :return: 聊天响应
        """
        if not session_id:
            session_id = f"session_{uuid.uuid4().hex[:12]}"

        # 保存用户消息
        user_msg = ChatMessage(
            user_id=user_id,
            session_id=session_id,
            role="user",
            content=message,
        )
        db.add(user_msg)
        db.flush()

        # RAG检索相关知识
        context_docs = vector_store_service.similarity_search(message, top_k=RAG_TOP_K)

        # 构建提示并调用LLM
        prompt = self._build_rag_prompt(message, context_docs)
        response = self.llm.invoke([
            SystemMessage(content="你是商城智能客服助手，请用中文回答。"),
            HumanMessage(content=prompt),
        ])
        answer = response.content

        # 保存AI回复
        ai_msg = ChatMessage(
            user_id=user_id,
            session_id=session_id,
            role="assistant",
            content=answer,
        )
        db.add(ai_msg)
        db.commit()
        db.refresh(user_msg)
        db.refresh(ai_msg)

        return {
            "session_id": session_id,
            "answer": answer,
            "messages": [user_msg, ai_msg],
        }

    def get_chat_history(
        self,
        db: Session,
        user_id: int,
        session_id: str,
        limit: int = 50,
    ) -> List[ChatMessage]:
        """
        获取聊天历史记录
        :param db: 数据库会话
        :param user_id: 用户ID
        :param session_id: 会话ID
        :param limit: 最大条数
        :return: 消息列表
        """
        return (
            db.query(ChatMessage)
            .filter(ChatMessage.user_id == user_id, ChatMessage.session_id == session_id)
            .order_by(ChatMessage.create_time.asc())
            .limit(limit)
            .all()
        )


# 全局单例
ai_service = AIService()
