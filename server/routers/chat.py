"""
AI智能客服聊天路由
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from database import get_db
from schemas.schemas import ChatRequest, ChatMessageOut
from services.ai_service import ai_service
from utils.deps import get_current_user
from utils.resp import success, error

router = APIRouter(prefix="/api/chat", tags=["AI智能客服"])


@router.post("/send")
def send_message(
    req: ChatRequest,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    """
    发送消息给AI智能客服(RAG增强)
    """
    if not req.message.strip():
        return error("消息不能为空")

    try:
        result = ai_service.chat(db, user.id, req.message, req.session_id)
        return success({
            "session_id": result["session_id"],
            "answer": result["answer"],
            "messages": [ChatMessageOut.model_validate(m).model_dump() for m in result["messages"]],
        })
    except Exception as e:
        return error(f"AI服务异常: {str(e)}", 500)


@router.get("/history")
def chat_history(
    session_id: str = Query(..., description="会话ID"),
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    """
    获取聊天历史记录
    """
    messages = ai_service.get_chat_history(db, user.id, session_id)
    return success([ChatMessageOut.model_validate(m).model_dump() for m in messages])
