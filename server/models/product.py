"""
商品ORM模型
"""
from sqlalchemy import Column, Integer, String, Text, Numeric, DateTime, func

from database import Base


class Product(Base):
    """商品表模型"""

    __tablename__ = "t_product"

    id = Column(Integer, primary_key=True, autoincrement=True, comment="商品ID")
    category_id = Column(Integer, nullable=False, comment="分类ID")
    name = Column(String(100), nullable=False, comment="商品名称")
    description = Column(Text, comment="商品描述")
    price = Column(Numeric(10, 2), nullable=False, comment="商品价格")
    stock = Column(Integer, default=0, comment="库存")
    image = Column(String(255), comment="商品主图")
    images = Column(Text, comment="商品图片(JSON数组)")
    sales = Column(Integer, default=0, comment="销量")
    status = Column(Integer, default=1, comment="状态:1上架0下架")
    create_time = Column(DateTime, server_default=func.now(), comment="创建时间")
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now(), comment="更新时间")
