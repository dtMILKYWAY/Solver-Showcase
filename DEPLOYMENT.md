# ButterMath 生产环境部署指南

本文档详细介绍如何将 ButterMath 部署到生产服务器，实现 24 小时不间断服务。

## 📋 目录

- [服务器要求](#服务器要求)
- [快速部署](#快速部署)
- [详细步骤](#详细步骤)
- [配置说明](#配置说明)
- [运维命令](#运维命令)
- [故障排查](#故障排查)

---

## 服务器要求

### 最低配置

| 项目 | 要求 |
|------|------|
| CPU | 1 核 |
| 内存 | 2 GB |
| 存储 | 20 GB SSD |
| 系统 | Ubuntu 20.04+ / Debian 11+ / CentOS 8+ |
| 网络 | 开放 80、443 端口 |

### 推荐配置

| 项目 | 要求 |
|------|------|
| CPU | 2 核 |
| 内存 | 4 GB |
| 存储 | 40 GB SSD |

### 软件要求

- Docker 20.10+
- Docker Compose 2.0+

---

## 快速部署

### 方式一：一键部署（推荐）

**1. 本地打包**

Windows:
```powershell
# 在项目根目录运行 PowerShell
powershell -ExecutionPolicy Bypass -File deploy-pack.ps1
```

Linux/Mac:
```bash
# 在项目根目录运行
chmod +x deploy-pack.sh
./deploy-pack.sh
```

**2. 上传到服务器**

```bash
# 替换 user 和 server_ip
scp buttermath-deploy-*.zip user@server_ip:/tmp/
```

**3. 服务器部署**

```bash
# SSH 登录服务器
ssh user@server_ip

# 安装 unzip（如果没有）
sudo apt install unzip -y

# 解压到目标目录
sudo mkdir -p /opt/buttermath
cd /opt/buttermath
sudo unzip /tmp/buttermath-deploy-*.zip

# 配置环境变量（重要！）
sudo cp backend/.env.example backend/.env
sudo nano backend/.env   # 编辑配置 API 密钥等

# 修改 Caddyfile 邮箱（重要！用于 SSL 证书）
sudo sed -i 's/your-email@example.com/你的真实邮箱@example.com/g' Caddyfile

# 运行部署脚本
sudo chmod +x deploy-server.sh
sudo ./deploy-server.sh
```

### 方式二：手动部署

```bash
# 1. 上传并解压代码到服务器
cd /opt/buttermath
sudo unzip buttermath-deploy-*.zip

# 2. 配置环境变量（必须！）
sudo cp backend/.env.example backend/.env
sudo nano backend/.env
# 至少需要配置 GEMINI_API_KEY

# 3. 修改 Caddyfile 邮箱
sudo nano Caddyfile
# 将 your-email@example.com 改为你的真实邮箱

# 4. 构建并启动
sudo docker compose up -d --build

# 5. 查看日志确认启动成功
sudo docker compose logs -f
```

---

## 详细步骤

### 1. 准备服务器

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装 Docker
curl -fsSL https://get.docker.com | sh

# 安装 Docker Compose（如果未自动安装）
sudo apt install docker-compose-plugin

# 将当前用户加入 docker 组（可选）
sudo usermod -aG docker $USER

# 启动 Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### 2. 配置防火墙

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# CentOS (firewalld)
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

### 3. 配置域名解析

在域名服务商处添加 DNS 记录：

| 类型 | 名称 | 值 |
|------|------|-----|
| A | @ | 服务器 IP |
| A | www | 服务器 IP |

### 4. 配置环境变量（必须步骤！）

**步骤说明：**

```bash
# 1. 复制示例文件
sudo cp backend/.env.example backend/.env

# 2. 编辑配置文件
sudo nano backend/.env
```

**必须修改的配置：**

| 变量 | 说明 | 示例 |
|------|------|------|
| `GEMINI_API_KEY` | **必须！** Gemini API 密钥 | `AIzaSy...` |

**可选修改的配置：**

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `GEMINI_MODEL` | 使用的模型 | `gemini-2.0-flash-exp` |
| `ENVIRONMENT` | 运行环境 | 改为 `production` |
| `LOG_LEVEL` | 日志级别 | `INFO` 或 `WARNING` |

**配置示例：**

```bash
# Gemini API 配置（必须修改！）
GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
GEMINI_BASE_URL=https://generativelanguage.googleapis.com
GEMINI_MODEL=gemini-2.0-flash-exp

# 服务器配置
PORT=8000
HOST=0.0.0.0

# 环境改为生产
ENVIRONMENT=production

# 日志级别
LOG_LEVEL=INFO
```

**获取 Gemini API Key：**
1. 访问 [Google AI Studio](https://aistudio.google.com/app/apikey)
2. 登录 Google 账号
3. 点击 "Create API Key" 创建密钥
4. 复制密钥到 `GEMINI_API_KEY`

### 5. 修改 Caddyfile（重要）

编辑 `Caddyfile`，将邮箱替换为你的真实邮箱：

```diff
- email your-email@example.com
+ email your-actual-email@example.com
```

### 6. 启动服务

```bash
# 构建并启动（首次部署）
docker compose up -d --build

# 查看启动日志
docker compose logs -f
```

---

## 配置说明

### Docker Compose 配置

```yaml
# docker-compose.yaml 主要配置说明

services:
  backend:
    # 资源限制
    deploy:
      resources:
        limits:
          memory: 1G      # 最大内存
        reservations:
          memory: 512M    # 保留内存
    
    # 自动重启策略
    restart: unless-stopped
  
  caddy:
    # 端口映射
    ports:
      - "80:80"    # HTTP
      - "443:443"  # HTTPS
```

### Caddy 配置

Caddyfile 主要功能：

- 自动 HTTPS（Let's Encrypt）
- HTTP → HTTPS 重定向
- API 反向代理（/api/* → backend:8000）
- 静态文件服务（SPA 路由）
- 安全头部
- 访问日志

---

## 运维命令

### 日常管理

```bash
# 查看服务状态
docker compose ps

# 查看实时日志
docker compose logs -f

# 查看后端日志
docker compose logs -f backend

# 查看最近 100 行日志
docker compose logs --tail=100

# 重启服务
docker compose restart

# 重启单个服务
docker compose restart backend
docker compose restart caddy

# 停止服务
docker compose down

# 停止并删除数据卷
docker compose down -v
```

### 更新部署

```bash
# 1. 上传新代码包
scp buttermath-deploy-*.tar.gz user@server:/opt/buttermath/

# 2. 解压覆盖
cd /opt/buttermath
tar -xzvf buttermath-deploy-*.tar.gz

# 3. 重新构建并启动
docker compose down
docker compose up -d --build

# 4. 查看日志确认
docker compose logs -f
```

### 日志管理

```bash
# 日志位置
# Docker 容器日志：docker logs buttermath-backend
# 应用日志：/opt/buttermath/logs/

# 查看应用日志
tail -f /opt/buttermath/logs/app.log

# 清理 Docker 日志
docker compose down
docker system prune -f
```

### SSL 证书管理

```bash
# Caddy 自动管理 SSL 证书
# 查看证书状态
docker exec buttermath-gateway caddy list-certificates

# 强制更新证书
docker exec buttermath-gateway caddy reload --config /etc/caddy/Caddyfile
```

---

## 故障排查

### 常见问题

#### 1. 服务无法启动

```bash
# 检查容器日志
docker compose logs backend

# 检查环境变量
docker compose config

# 检查端口占用
sudo netstat -tlnp | grep -E '80|443|8000'
```

#### 2. API 请求失败

```bash
# 检查后端健康状态
curl http://localhost:8000/health

# 检查 API 密钥配置
docker exec buttermath-backend env | grep API_KEY
```

#### 3. SSL 证书问题

```bash
# 检查 Caddy 日志
docker compose logs caddy

# 确认域名解析正确
dig anndysstar.cn

# 确认端口开放
curl -I https://anndysstar.cn
```

#### 4. 前端页面空白

```bash
# 检查前端文件是否存在
docker exec buttermath-backend ls -la /app/frontend/dist/

# 检查 Caddy 配置
docker exec buttermath-gateway cat /etc/caddy/Caddyfile
```

### 健康检查

```bash
# 后端健康检查
curl http://localhost:8000/health

# 网关健康检查
curl http://localhost/health

# 完整链路检查
curl https://anndysstar.cn/api/health
```

---

## 📦 需要打包的文件清单

### ✅ 必须打包

```
backend/                 # 后端源码
├── app.py
├── main.py
├── prompts.py
├── middleware.py
├── security_config.py
├── pyproject.toml
├── uv.lock
└── .env.example

frontend/                # 前端源码（Docker 内构建）
├── src/
├── public/
├── package.json
├── vite.config.ts
└── tsconfig.json

Dockerfile               # Docker 构建文件
docker-compose.yaml      # Docker Compose 配置
Caddyfile               # Caddy 配置
.dockerignore           # Docker 忽略文件
```

### ❌ 不需要打包

| 文件/目录 | 原因 |
|-----------|------|
| `node_modules/` | 依赖，构建时安装 |
| `frontend/dist/` | 构建产物，Docker 内生成 |
| `.venv/` | Python 虚拟环境 |
| `logs/` | 日志目录 |
| `.env` | 敏感信息，服务器单独配置 |
| `tietu/` | 开发素材 |
| `design-system/` | 设计文档 |
| `*.md` | 文档（除 README.md） |
| `coverage/` | 测试覆盖率 |
| `e2e/` | 端到端测试 |

---

## 🔒 安全建议

1. **定期更新**：定期更新 Docker 基础镜像和依赖
2. **备份数据**：定期备份 SSL 证书数据卷
3. **监控日志**：设置日志监控和告警
4. **限制访问**：使用防火墙限制非必要端口访问
5. **API 密钥保护**：不要将 `.env` 文件提交到版本控制

---

## 📞 支持

如遇问题，请检查：
1. Docker 服务是否正常运行
2. 环境变量是否正确配置
3. 域名解析是否正确
