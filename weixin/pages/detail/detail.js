/**
 * 商品详情页
 */
const { get, post } = require('../../utils/request')
const { formatImageUrl } = require('../../utils/format')

Page({
  data: { product: null, productId: 0 },

  onLoad(options) {
    this.setData({ productId: options.id })
    this.loadProduct(options.id)
  },

  async loadProduct(id) {
    try {
      const res = await get(`/product/detail/${id}`)
      const product = res.data
      if (product) product.image = formatImageUrl(product.image)
      this.setData({ product })
    } catch (e) {}
  },

  /** 加入购物车 */
  async addCart() {
    try {
      await post('/cart/add', { product_id: Number(this.data.productId), quantity: 1 })
      wx.showToast({ title: '已加入购物车', icon: 'success' })
    } catch (e) {}
  },

  /** 立即购买 */
  buyNow() {
    const p = this.data.product
    wx.navigateTo({
      url: `/pages/order-confirm/order-confirm?items=${JSON.stringify([{product_id: p.id, quantity: 1}])}`,
    })
  },
})
