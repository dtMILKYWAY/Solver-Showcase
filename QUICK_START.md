# 快速配置指南

## 📝 配置 Gemini API

### 1. 编辑后端环境变量文件

打开文件：`backend/.env`

```bash
# Gemini API 配置
GEMINI_API_KEY=你的API密钥
GEMINI_BASE_URL=https://你的中转商地址
GEMINI_MODEL=gemini-2.0-flash-exp

# 服务器配置
PORT=8000
HOST=0.0.0.0

# 环境
ENVIRONMENT=development

# CORS（如果需要）
CORS_ORIGINS=http://localhost:5173,http://localhost:3000

# 日志级别
LOG_LEVEL=INFO
```

### 2. 获取 Gemini API Key

如果你使用的是官方 Gemini API：
- 访问：https://makersuite.google.com/app/apikey
- 创建 API Key
- 复制并粘贴到 `backend/.env` 文件的 `GEMINI_API_KEY` 后面

如果你使用的是中转商 API：
- 将中转商地址粘贴到 `GEMINI_BASE_URL`
- 将中转商提供的密钥粘贴到 `GEMINI_API_KEY`
- 确认模型名称（通常为 `gemini-2.0-flash-exp` 或 `gemini-1.5-flash`）

### 3. 启动服务

#### 后端启动
```bash
cd backend
uv sync  # 首次运行需要安装依赖
uv run python app.py
```

后端将运行在：http://localhost:8000

#### 前端启动
```bash
cd frontend
pnpm install  # 首次运行需要安装依赖
pnpm dev
```

前端将运行在：http://localhost:5173

### 4. 测试应用

1. 打开浏览器访问：http://localhost:5173
2. 在输入框中输入数学问题，例如：
   - `2x + 5 = 15，求 x`
   - `计算 (3 + 4) × 5`
   - `求解方程 x² - 5x + 6 = 0`
3. 点击"开始解题"按钮
4. 等待 AI 返回解题步骤和答案

## 🎯 常见问题

### Q: 后端启动失败？
A: 检查是否安装了 uv：
```bash
pip install uv
```

### Q: 前端无法连接后端？
A: 确保后端运行在 http://localhost:8000，前端会自动代理 `/api` 请求

### Q: API 调用失败？
A: 检查 `backend/.env` 文件中的 API Key 和 Base URL 是否正确

### Q: 想使用其他 Gemini 模型？
A: 修改 `backend/.env` 中的 `GEMINI_MODEL`，可选值：
- `gemini-2.0-flash-exp`（最新，推荐）
- `gemini-1.5-flash`（快速）
- `gemini-1.5-pro`（高质量）

## 🚀 生产环境部署

使用 Docker Compose：
```bash
docker-compose up -d
```

访问：http://localhost

## 📚 API 文档

启动后端后，访问：
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

---

祝你使用愉快！🎉
