/**
 * 网络请求封装
 * 统一处理Token和响应
 */
const BASE_URL = 'http://127.0.0.1:8000/api'
/** 静态资源根地址（图片等，不含 /api） */
const FILE_BASE_URL = BASE_URL.replace(/\/api$/, '')

/**
 * 发起HTTP请求
 * @param {Object} options - 请求配置
 * @returns {Promise} 请求结果
 */
function request(options) {
  return new Promise((resolve, reject) => {
    const token = wx.getStorageSync('token') || ''
    wx.request({
      url: BASE_URL + options.url,
      method: options.method || 'GET',
      data: options.data || {},
      header: {
        'Content-Type': 'application/json',
        'Authorization': token ? `Bearer ${token}` : '',
        ...options.header,
      },
      success(res) {
        if (res.data.code === 200) {
          resolve(res.data)
        } else if (res.data.code === 401) {
          wx.removeStorageSync('token')
          wx.redirectTo({ url: '/pages/login/login' })
          reject(res.data)
        } else {
          wx.showToast({ title: res.data.msg || '请求失败', icon: 'none' })
          reject(res.data)
        }
      },
      fail(err) {
        wx.showToast({ title: '网络错误', icon: 'none' })
        reject(err)
      },
    })
  })
}

/** GET请求 */
function get(url, data) {
  return request({ url, method: 'GET', data })
}

/** POST请求 */
function post(url, data) {
  return request({ url, method: 'POST', data })
}

/** PUT请求 */
function put(url, data) {
  return request({ url, method: 'PUT', data })
}

/** DELETE请求 */
function del(url, data) {
  return request({ url, method: 'DELETE', data })
}

/**
 * 上传文件
 * @param {string} url - 接口路径
 * @param {string} filePath - 本地临时文件路径
 * @returns {Promise} 上传结果
 */
function uploadFile(url, filePath) {
  return new Promise((resolve, reject) => {
    const token = wx.getStorageSync('token') || ''
    wx.uploadFile({
      url: BASE_URL + url,
      filePath,
      name: 'file',
      header: {
        Authorization: token ? `Bearer ${token}` : '',
      },
      success(res) {
        let data = {}
        try {
          data = JSON.parse(res.data)
        } catch (e) {
          wx.showToast({ title: '上传失败', icon: 'none' })
          reject(e)
          return
        }
        if (data.code === 200) {
          resolve(data)
        } else if (data.code === 401) {
          wx.removeStorageSync('token')
          wx.removeStorageSync('userInfo')
          wx.redirectTo({ url: '/pages/login/login' })
          reject(data)
        } else {
          wx.showToast({ title: data.msg || '上传失败', icon: 'none' })
          reject(data)
        }
      },
      fail(err) {
        wx.showToast({ title: '网络错误', icon: 'none' })
        reject(err)
      },
    })
  })
}

/** 拼接完整图片地址 */
function resolveImageUrl(url) {
  if (!url) return ''
  if (url.startsWith('http://') || url.startsWith('https://')) return url
  return FILE_BASE_URL + url
}

module.exports = { request, get, post, put, del, uploadFile, resolveImageUrl, BASE_URL, FILE_BASE_URL }
