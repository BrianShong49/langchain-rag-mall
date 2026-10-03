"""
知识库管理路由
支持txt/doc/pdf/markdown文件上传、解析、向量化
"""
import shutil
import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, UploadFile, File, Query
from sqlalchemy.orm import Session

from config import KNOWLEDGE_DIR
from database import get_db
from models.knowledge import KnowledgeFile
from schemas.schemas import KnowledgeFileOut
from services.file_parser import parse_file, get_file_type
from services.vector_store import vector_store_service
from utils.deps import get_current_admin
from utils.resp import success, error, page_result

router = APIRouter(prefix="/api/knowledge", tags=["知识库管理"])

# 允许上传的文件类型
ALLOWED_TYPES = {"txt", "doc", "docx", "pdf", "md", "markdown"}


@router.get("/admin/list")
def knowledge_list(
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    db: Session = Depends(get_db),
    admin=Depends(get_current_admin),
):
    """管理员分页查询知识库文件列表"""
    query = db.query(KnowledgeFile)
    total = query.count()
    items = query.order_by(KnowledgeFile.id.desc()).offset((page - 1) * page_size).limit(page_size).all()
    return success(page_result(
        [KnowledgeFileOut.model_validate(i).model_dump() for i in items],
        total, page, page_size,
    ))


@router.post("/admin/upload")
async def upload_knowledge(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    admin=Depends(get_current_admin),
):
    """
    上传知识库文件并自动解析向量化
    支持格式: txt, doc, pdf, markdown
    """
    file_type = get_file_type(file.filename)
    if file_type not in ALLOWED_TYPES and file.filename.split(".")[-1].lower() not in ALLOWED_TYPES:
        return error("不支持的文件格式，仅支持 txt/doc/pdf/markdown")

    # 保存文件到 D:/uploads14/knowledge/
    ext = Path(file.filename).suffix
    save_name = f"{uuid.uuid4().hex}{ext}"
    save_path = KNOWLEDGE_DIR / save_name

    with open(save_path, "wb") as f:
        shutil.copyfileobj(file.file, f)

    file_size = save_path.stat().st_size

    # 创建数据库记录
    kf = KnowledgeFile(
        file_name=file.filename,
        file_type=file_type,
        file_path=str(save_path).replace("\\", "/"),
        file_size=file_size,
        status=0,
    )
    db.add(kf)
    db.commit()
    db.refresh(kf)

    # 异步解析并向量化
    try:
        text = parse_file(str(save_path), file_type)
        chunk_count = vector_store_service.add_documents(text, kf.id, kf.file_name)
        kf.status = 1
        kf.chunk_count = chunk_count
    except Exception as e:
        kf.status = 2
        kf.error_msg = str(e)[:500]

    db.commit()
    db.refresh(kf)
    return success(KnowledgeFileOut.model_validate(kf).model_dump(), "上传成功")


@router.post("/admin/{file_id}/vectorize")
def vectorize_knowledge(
    file_id: int,
    db: Session = Depends(get_db),
    admin=Depends(get_current_admin),
):
    """重新向量化知识库文件"""
    kf = db.query(KnowledgeFile).filter(KnowledgeFile.id == file_id).first()
    if not kf:
        return error("文件不存在", 404)

    try:
        vector_store_service.delete_by_file_id(kf.id)
        text = parse_file(kf.file_path, kf.file_type)
        chunk_count = vector_store_service.add_documents(text, kf.id, kf.file_name)
        kf.status = 1
        kf.chunk_count = chunk_count
        kf.error_msg = None
    except Exception as e:
        kf.status = 2
        kf.error_msg = str(e)[:500]

    db.commit()
    return success(None, "向量化完成" if kf.status == 1 else "向量化失败")


@router.delete("/admin/{file_id}")
def delete_knowledge(
    file_id: int,
    db: Session = Depends(get_db),
    admin=Depends(get_current_admin),
):
    """删除知识库文件"""
    kf = db.query(KnowledgeFile).filter(KnowledgeFile.id == file_id).first()
    if not kf:
        return error("文件不存在", 404)

    vector_store_service.delete_by_file_id(kf.id)
    try:
        Path(kf.file_path).unlink(missing_ok=True)
    except Exception:
        pass

    db.delete(kf)
    db.commit()
    return success(None, "删除成功")
