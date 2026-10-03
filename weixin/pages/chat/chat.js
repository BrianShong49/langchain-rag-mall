/**
 * AI智能客服对话页面
 * 基于LangChain RAG增强检索
 */
const { post } = require('../../utils/request')
const { formatDateTime } = require('../../utils/format')

Page({
  data: {
    messages: [],
    inputText: '',
    sessionId: '',
    loading: false,
    scrollTo: '',
  },

  onLoad() {
    if (!wx.getStorageSync('token')) {
      wx.redirectTo({ url: '/pages/login/login' })
    }
    // 欢迎消息
    this.setData({
      messages: [{
        id: 0, role: 'assistant',
        content: '您好！我是AI智能客服，有什么可以帮您的吗？',
        time: formatDateTime(new Date()),
      }],
    })
  },

  onInput(e) { this.setData({ inputText: e.detail.value }) },

  /** 发送消息给AI客服 */
  async sendMessage() {
    const text = this.data.inputText.trim()
    if (!text || this.data.loading) return

    const userMsg = {
      id: Date.now(), role: 'user', content: text,
      time: formatDateTime(new Date()),
    }
    const newMessages = [...this.data.messages, userMsg]
    this.setData({
      messages: newMessages,
      inputText: '',
      loading: true,
      scrollTo: `msg-${newMessages.length - 1}`,
    })

    try {
      const res = await post('/chat/send', {
        message: text,
        session_id: this.data.sessionId || undefined,
      })
      const aiMsg = {
        id: Date.now() + 1, role: 'assistant', content: res.data.answer,
        time: formatDateTime(new Date()),
      }
      this.setData({
        messages: [...newMessages, aiMsg],
        sessionId: res.data.session_id,
        loading: false,
        scrollTo: `msg-${newMessages.length}`,
      })
    } catch (e) {
      this.setData({ loading: false })
    }
  },
})
