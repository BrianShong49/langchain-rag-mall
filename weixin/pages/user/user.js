/**
 * 我的页面
 */
const { get, resolveImageUrl } = require('../../utils/request')

Page({
  data: {
    userInfo: {},
    avatarUrl: '',
    avatarText: 'U',
  },

  onShow() {
    const token = wx.getStorageSync('token')
    if (!token) {
      wx.redirectTo({ url: '/pages/login/login' })
      return
    }
    this.loadUserInfo()
  },

  /** 加载用户信息 */
  async loadUserInfo() {
    try {
      const res = await get('/user/profile/me')
      const user = res.data
      const cached = wx.getStorageSync('userInfo') || {}
      const userInfo = {
        ...cached,
        username: user.username,
        nickname: user.nickname,
        avatar: user.avatar,
        phone: user.phone,
      }
      wx.setStorageSync('userInfo', userInfo)
      this.updateDisplay(userInfo)
    } catch (e) {
      const userInfo = wx.getStorageSync('userInfo') || {}
      this.updateDisplay(userInfo)
    }
  },

  updateDisplay(userInfo) {
    const nickname = userInfo.nickname || userInfo.username || ''
    this.setData({
      userInfo,
      avatarUrl: resolveImageUrl(userInfo.avatar),
      avatarText: nickname ? nickname[0].toUpperCase() : 'U',
    })
  },

  goProfile() {
    wx.navigateTo({ url: '/pages/profile/profile' })
  },

  goAddress() {
    wx.navigateTo({ url: '/pages/address-list/address-list' })
  },

  goOrders() {
    wx.navigateTo({ url: '/pages/order-list/order-list' })
  },

  goChat() {
    wx.navigateTo({ url: '/pages/chat/chat' })
  },

  handleLogout() {
    wx.removeStorageSync('token')
    wx.removeStorageSync('userInfo')
    wx.redirectTo({ url: '/pages/login/login' })
  },
})
