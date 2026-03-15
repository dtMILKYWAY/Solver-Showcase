# 📱 移动端测试指南

> **最后更新**: 2026-02-05
> **项目路径**: `d:\ProgramData\math-solver-love`

---

## 🎯 快速开始

### 方法 1: 局域网访问（推荐）- 真实手机测试

#### 步骤 1: 获取你的电脑 IP

**Windows PowerShell**:
```powershell
ipconfig | Select-String "IPv4"
```

**Linux/Mac**:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

你会看到类似这样的输出:
```
IPv4 地址 . . . . . . . . . . . : 192.168.1.100
```

#### 步骤 2: 配置防火墙

**Windows (需要管理员权限)**:
```powershell
# 添加前端端口 5174
New-NetFirewallRule -DisplayName "ButterMath Frontend" -Direction Inbound -LocalPort 5174 -Protocol TCP -Action Allow

# 添加后端端口 8000
New-NetFirewallRule -DisplayName "ButterMath Backend" -Direction Inbound -LocalPort 8000 -Protocol TCP -Action Allow
```

**Linux**:
```bash
sudo ufw allow 5174/tcp
sudo ufw allow 8000/tcp
```

#### 步骤 3: 手机访问

1. 📱 打开手机浏览器（Chrome/Safari/微信内置浏览器）
2. 📲 确保手机连接到和电脑相同的 WiFi
3. 🌐 在地址栏输入: `http://你的电脑IP:5174`
4. ✨ 开始测试！

**示例**:
```
http://192.168.1.100:5174
```

---

### 方法 2: 开发者工具模拟

**在电脑浏览器**中：
1. 按 **F12** 打开开发者工具
2. 按 **Ctrl + Shift + M** 切换设备工具栏
3. 选择设备预设：
   - iPhone 12 Pro / 13 Pro / 14 Pro
   - iPad Pro
   - Samsung Galaxy S21
4. 调整网络速度（可选）:
   - 点击 "Network" 下拉
   - 选择 "Mid-tier" (3G) 或 "Low-end" (4G)
5. 刷新页面测试

---

### 方法 3: 二维码访问（可选）

#### 生成二维码页面

**在电脑浏览器**中打开二维码测试页面:
```
file:///d:/ProgramData/math-solver-love/qrcode-test.html
```

然后：
1. 📱 打开手机微信、支付宝或浏览器
2. 📸 扫描页面上的二维码
3. 🌐 在手机中打开链接

> ⚠️ 注意：二维码页面需要先更新 IP 地址

---

## ✅ 测试清单

### 移动端测试 (< 1024px)
- [ ] 页面正常加载
- [ ] 布局是单列堆叠
- [ ] 底部导航栏显示
- [ ] Logo 旋转动画流畅
- [ ] 文字大小合适（最小 14px）
- [ ] 按钮容易点击（≥ 44x44px）
- [ ] 可以滚动查看所有内容
- [ ] 无水平滚动
- [ ] 输入框可以输入文字
- [ ] 点击"开始解题"有反馈
- [ ] Glass 效果渲染正常
- [ ] 渐变背景显示正常

### PC 端测试 (≥ 1024px)
- [ ] 页面正常加载
- [ ] 布局是左右双列
- [ ] 欢迎卡片显示
- [ ] 示例问题显示
- [ ] 顶部有"历史记录"和"使用教程"按钮
- [ ] 调整窗口大小，在 1024px 处布局切换
- [ ] 悬停效果正常

### 响应式断点测试
- [ ] < 640px (小手机): 单列，底部导航
- [ ] 640px - 1024px (平板/大手机): 单列，优化间距
- [ ] ≥ 1024px (桌面): 双列，顶部导航
- [ ] 过渡流畅，没有布局跳动

---

## 🔧 常见问题

### Q1: 手机无法访问（连接被拒绝）

**原因**:
- 防火墙阻止了连接
- Vite 未配置允许外部访问

**解决方案**:

1. **检查 Vite 配置** (`frontend/vite.config.ts`):
```typescript
export default defineConfig({
  server: {
    host: '0.0.0.0',  // 允许外部访问
    port: 5174,
  },
  // ...
})
```

2. **重启前端服务**:
```bash
cd frontend
pnpm dev
```

3. **关闭防火墙或添加例外** (见上方步骤 2)

---

### Q2: 页面显示"找不到服务器"

**原因**: 前端服务未运行

**解决**:
```bash
cd frontend
pnpm dev
```

应该看到:
```
VITE ready in xxx ms
➜ Local:   http://localhost:5174/
➜ Network: http://192.168.x.x:5174/
```

---

### Q3: 可以访问但无法解题

**原因**: 后端 API 未运行或 API Key 未配置

**解决**:

1. **检查后端是否运行**:
```bash
cd backend
uv run python app.py
```

2. **检查 API Key 配置**:
```bash
# 编辑 backend/.env
GEMINI_API_KEY=你的真实API密钥
```

3. **测试健康检查**:
```
http://你的电脑IP:8000/health
```

---

### Q4: 跨域错误 (CORS)

**原因**: 后端 CORS 配置问题

**解决**:

检查 `backend/.env`:
```bash
CORS_ORIGINS=http://localhost:5174,http://192.168.1.100:5174
```

重启后端:
```bash
cd backend
uv run python app.py
```

---

## 📊 响应式断点说明

### Tailwind 默认断点
| 断点 | 宽度 | 设备 |
|------|------|------|
| `sm` | ≥ 640px | 大手机 |
| `md` | ≥ 768px | 平板竖屏 |
| `lg` | ≥ 1024px | 平板横屏/桌面 |
| `xl` | ≥ 1280px | 大桌面 |
| `2xl` | ≥ 1536px | 超大屏 |

### 本项目断点
- **移动端**: < 1024px (单列 + 底部导航)
- **PC 端**: ≥ 1024px (双列 + 顶部导航)

---

## 🎨 功能测试建议

### 基础功能
1. ✅ 页面加载速度 (< 2s on 4G)
2. ✅ 响应式布局切换
3. ✅ 动画流畅度 (60fps)
4. ✅ 按钮触摸反馈

### 核心功能（需要 API Key）
1. ⚠️ 输入数学问题
2. ⚠️ 点击"开始解题"
3. ⚠️ 查看解题结果
4. ⚠️ 查看解题步骤
5. ⚠️ 复制答案

> ⚠️ 注意：需要先配置 Gemini API Key 才能正常解题

### 交互功能
1. ❌ 点击示例问题
2. ❌ 切换文字/相机标签
3. ❌ 打开历史记录
4. ❌ 点击"清空"按钮
5. ❌ 保存题目
6. ❌ 使用教程

---

## 📝 性能测试

### Lighthouse 测试（Chrome DevTools）

**目标指标**:
| 指标 | 目标 | 说明 |
|------|------|------|
| Performance | > 90 | 性能评分 |
| Accessibility | > 90 | 无障碍评分 |
| Best Practices | > 90 | 最佳实践 |
| SEO | > 80 | SEO 优化 |
| FCP | < 1.5s | 首次内容绘制 |
| LCP | < 2.5s | 最大内容绘制 |
| CLS | < 0.1 | 累积布局偏移 |
| FID | < 100ms | 首次输入延迟 |

---

## 🔗 访问地址汇总

### 电脑端
```
本地:    http://localhost:5174
局域网:  http://你的电脑IP:5174
```

### 移动端
```
WiFi:    http://你的电脑IP:5174
```

### API 端点
```
后端:        http://你的电脑IP:8000
健康检查:     http://你的电脑IP:8000/health
Swagger 文档: http://你的电脑IP:8000/docs
ReDoc 文档:   http://你的电脑IP:8000/redoc
```

---

## 📱 测试设备建议

### 推荐测试设备

**iOS**:
- iPhone SE (小屏)
- iPhone 12/13/14 Pro (主流)
- iPad Pro (平板)

**Android**:
- Samsung Galaxy S21/S22
- Google Pixel 6/7
- 小米/华为手机

**浏览器**:
- Safari (iOS)
- Chrome (Android)
- 微信内置浏览器
- 支付宝内置浏览器

---

## 🚀 现在开始测试！

### 步骤 1: 确认服务运行

```bash
# 检查前端（应返回 HTML）
curl http://localhost:5174

# 检查后端（应返回 JSON）
curl http://localhost:8000/health
```

### 步骤 2: 获取 IP 地址

```bash
# Windows
ipconfig

# Linux/Mac
ifconfig
```

### 步骤 3: 手机访问

1. 打开手机浏览器
2. 输入: `http://你的电脑IP:5174`
3. 等待页面加载
4. 开始测试！

### 步骤 4: 反馈结果

- 哪些功能正常？✅
- 哪些有问题？❌
- 需要调整什么？🔧
- 性能如何？⚡

---

## 🐛 问题反馈模板

发现问题时，请提供以下信息：

```
### 问题描述
简要描述问题

### 设备信息
- 设备型号: iPhone 13 Pro
- 操作系统: iOS 16.5
- 浏览器: Safari / Chrome
- 屏幕尺寸: 390 x 844

### 问题截图
[附上截图]

### 复现步骤
1. 打开页面
2. 点击某个按钮
3. 期望看到...
4. 实际看到...

### 控制台错误
[附上浏览器控制台错误信息]
```

---

**祝你测试愉快！** 🎉

如有任何问题，随时告诉我！

---

**文档版本**: v1.1
**最后更新**: 2026-02-05
**维护者**: ButterMath Team
