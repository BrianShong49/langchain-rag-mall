/**
 * 首页
 */
const { get } = require('../../utils/request')
const { formatImageUrl } = require('../../utils/format')

Page({
  data: { banners: [], products: [] },

  onShow() {
    const token = wx.getStorageSync('token')
    if (!token) {
      wx.redirectTo({ url: '/pages/login/login' })
      return
    }
    this.loadData()
  },

  /** 加载轮播图和商品 */
  async loadData() {
    try {
      const [bannerRes, productRes] = await Promise.all([
        get('/banner/list'),
        get('/product/list', { page: 1, page_size: 20 }),
      ])
      this.setData({
        banners: (bannerRes.data || []).map(b => ({ ...b, image: formatImageUrl(b.image) })),
        products: (productRes.data?.list || []).map(p => ({ ...p, image: formatImageUrl(p.image) })),
      })
    } catch (e) {}
  },

  /** 跳转商品详情 */
  goDetail(e) {
    wx.navigateTo({ url: `/pages/detail/detail?id=${e.currentTarget.dataset.id}` })
  },
})
