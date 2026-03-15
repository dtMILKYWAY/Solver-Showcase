# 头像功能实现文档

## 功能概述

实现了完整的头像上传和 AI 生成功能，支持 PC 和移动端。

## 功能特性

### 1. 头像上传 (AvatarUpload 组件)
- 支持点击上传图片
- 支持拖拽上传
- 支持移动端相机拍摄 (capture="user")
- 上传进度显示
- 圆形裁剪预览
- 悬停显示相机图标
- 文件类型和大小验证 (最大 5MB)

### 2. AI 生成头像 (AIGenerateModal 组件)
- 自定义提示词输入 (最大 200 字符)
- 随机提示词示例
- 4 种风格选择:
  - 可爱风 (cute) - 粉色主题
  - 动漫风 (anime) - 蓝色主题
  - Q版风 (chibi) - 黄色主题
  - 卡通风 (cartoon) - 绿色主题
- 实时生成进度显示
- 生成结果预览
- 支持重新生成

### 3. 极致动画体验
- 头像区域悬停缩放效果
- AI 生成按钮呼吸动画 + 摇晃效果
- 进度环动画
- 弹窗进入/退出弹簧动画
- 生成步骤文字切换动画
- 加载点跳动动画

## 文件结构

```
frontend/src/components/chiikawa/ui/
├── AvatarUpload.tsx      # 头像上传组件
├── AIGenerateModal.tsx   # AI 生图弹窗组件
└── index.ts              # 组件导出

backend/app.py
├── POST /api/avatar/upload    # 头像上传接口
└── POST /api/avatar/generate  # AI 生成头像接口

frontend/src/components/chiikawa/pages/
└── ProfilePage.tsx       # 集成头像功能的个人中心页
```

## API 接口

### POST /api/avatar/upload
上传图片作为头像

**请求**: `multipart/form-data`
- `file`: 图片文件 (JPEG, PNG, GIF, WebP)

**响应**:
```json
{
  "success": true,
  "image_url": "data:image/jpeg;base64,...",
  "message": "头像上传成功",
  "filename": "avatar.jpg",
  "size": 1024,
  "mime_type": "image/jpeg"
}
```

### POST /api/avatar/generate
使用 AI 生成头像

**请求**:
```json
{
  "prompt": "可爱女孩，粉色头发",
  "style": "cute"
}
```

**响应**:
```json
{
  "success": true,
  "image_url": "data:image/png;base64,...",
  "message": "头像生成成功"
}
```

## 使用说明

### 前端使用
```tsx
import { AvatarUpload } from './components/chiikawa/ui'

// 基础使用
<AvatarUpload
  currentAvatar={avatarUrl}
  onAvatarChange={handleAvatarChange}
  size={96}
/>

// 完整功能
<AvatarUpload
  currentAvatar={avatarUrl}
  onAvatarChange={handleAvatarChange}
  size={96}
  showAIGenerate={true}
  onAIGenerateClick={() => setShowModal(true)}
  isLoading={isGenerating}
/>
```

### 数据持久化
头像数据保存在 localStorage 中，key 为 `user_avatar`。

## 设计亮点

1. **Chiikawa 主题一致性**: 使用项目现有的配色系统和阴影系统
2. **移动端优化**: 触摸目标大小符合 44x44px 规范
3. **无障碍支持**: 所有按钮都有 aria-label
4. **错误处理**: 上传和生成都有完善的错误提示
5. **加载状态**: 多种加载动画提供即时反馈

## 依赖

- framer-motion: 动画库
- lucide-react: 图标库
- FastAPI: 后端框架

## 模型配置

AI 生图使用模型: `gemini-3.1-flash-image-preview`
API Key 从环境变量 `GEMINI_API_KEY` 读取
Base URL 从环境变量 `GEMINI_BASE_URL` 读取
