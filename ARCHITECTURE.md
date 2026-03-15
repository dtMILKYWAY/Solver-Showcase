# ButterMath Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         User (Mobile PWA)                       │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ HTTPS
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Caddy Reverse Proxy                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  • TLS Termination                                       │  │
│  │  • Static File Serving (Frontend)                        │  │
│  │  • API Reverse Proxy → Backend                           │  │
│  │  • Health Check Monitoring                               │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────┬──────────────────────────────┬────────────────────┘
              │                              │
              │ /api/*                       │ /* (static)
              ▼                              ▼
┌───────────────────────────┐    ┌──────────────────────────────┐
│   Backend (Granian)       │    │   Frontend (React 19)        │
│  ┌─────────────────────┐  │    │  ┌───────────────────────┐  │
│  │  FastAPI Application│  │    │  │  React Components     │  │
│  │                     │  │    │  │  - App.tsx            │  │
│  │  Endpoints:         │  │    │  │  - Button.tsx         │  │
│  │  • GET /health      │  │    │  │  - Card.tsx           │  │
│  │  • POST /api/solve  │  │    │  │                       │  │
│  │    /text            │  │    │  │  Styling:             │  │
│  │  • POST /api/solve  │  │    │  │  - Tailwind CSS v4    │  │
│  │    /image           │  │    │  │  - Soft Pastel Theme  │  │
│  │                     │  │    │  │  - Framer Motion      │  │
│  │  Middleware:        │  │    │  └───────────────────────┘  │
│  │  • CORS             │  │    └──────────────────────────────┘
│  │  • Loguru Logging   │  │
│  │  • File Cleanup     │  │
│  └─────────────────────┘  │
│                           │
│  Dependencies:            │
│  • FastAPI                │
│  • Granian (ASGI)         │
│  • Dashscope (AI)         │
│  • Loguru                 │
└───────────────────────────┘
         │
         │ AI API Calls
         ▼
┌───────────────────────────┐
│    Dashscope AI           │
│  (Math Problem Solving)   │
└───────────────────────────┘
```

## Component Details

### Frontend Architecture

```
frontend/
├── src/
│   ├── components/
│   │   ├── Button.tsx          # Reusable button with variants
│   │   └── Card.tsx            # Reusable card component
│   ├── lib/
│   │   └── utils.ts            # cn() utility for classNames
│   ├── App.tsx                 # Main application container
│   │   ├── Header (sticky, glass-effect)
│   │   ├── Tabs (Text/Camera)
│   │   ├── Input Area (animated)
│   │   ├── Solution Display (with steps)
│   │   ├── Bottom Navigation
│   │   └── History Sidebar
│   ├── index.css               # Tailwind v4 + theme variables
│   └── main.tsx                # React entry point
├── index.html                  # PWA meta tags
├── vite.config.ts              # Vite + Tailwind v4 + API proxy
└── package.json                # React 19 dependencies
```

### Backend Architecture

```
backend/
├── app.py                      # FastAPI application
│   ├── Lifespan Manager
│   │   ├── Startup (logger init)
│   │   └── Shutdown (cleanup)
│   ├── Endpoints
│   │   ├── GET /health
│   │   ├── POST /api/solve/text
│   │   └── POST /api/solve/image
│   └── Middleware
│       ├── Loguru (rotation, retention)
│       └── Temp File Cleanup
├── pyproject.toml              # uv dependencies
└── .env.example                # Environment template
```

## Data Flow

### Text Problem Solving

```
User Input (Text)
    │
    ▼
Frontend: App.tsx (state: input)
    │
    │ POST /api/solve/text
    │ { problem: "...", language: "zh" }
    ▼
Backend: FastAPI endpoint
    │
    │ AI Processing (Dashscope)
    ▼
Response: {
  solution: "...",
  steps: ["...", "..."],
  answer: "..."
}
    │
    ▼
Frontend: Animate solution display
```

### Image Problem Solving

```
User Input (Camera)
    │
    ▼
Frontend: Capture image
    │
    │ POST /api/solve/image
    │ multipart/form-data: file
    ▼
Backend: Save to temp file
    │
    │ OCR + AI Processing (Dashscope)
    ▼
Response: {
  solution: "...",
  steps: ["...", "..."],
  answer: "..."
}
    │
    │ Cleanup temp file (finally block)
    ▼
Frontend: Animate solution display
```

## Technology Choices

### Why This Stack?

| Component | Choice | Reason |
|-----------|--------|--------|
| **Backend Runtime** | Python 3.12 + uv | Fastest Python package manager, modern syntax |
| **ASGI Server** | Granian | 2x faster than uvicorn, Rust-based |
| **Web Framework** | FastAPI | Modern, async, OpenAPI auto-generated |
| **Logging** | Loguru | Simple, powerful, rotation built-in |
| **Frontend** | React 19 | Latest features, concurrent rendering |
| **Build Tool** | Vite 6 | Lightning-fast HMR, optimized builds |
| **CSS** | Tailwind v4 | Latest version, @import syntax, @theme |
| **Animations** | Framer Motion | Production-ready, GPU-accelerated |
| **Reverse Proxy** | Caddy | Auto HTTPS, simple config |
| **Container** | Docker | Industry standard, reproducible builds |

### ZeroOps Features

1. **Auto-scaling Logs**
   - 10MB rotation (prevents disk fill)
   - 7-day retention (storage control)
   - ZIP compression (saves space)

2. **Health Monitoring**
   - Built-in `/health` endpoint
   - Docker HEALTHCHECK support
   - Caddy health monitoring

3. **Automatic Cleanup**
   - Temp files deleted in `finally` blocks
   - No manual intervention needed
   - Prevents disk space issues

4. **Graceful Shutdown**
   - Lifespan hooks for cleanup
   - Connection draining
   - Resource release

## Performance Optimizations

### Frontend
- ✅ Framer Motion (GPU-accelerated animations)
- ✅ Tailwind v4 (minimal CSS, purged)
- ✅ AnimatePresence (efficient DOM transitions)
- ✅ Lazy loading ready
- ✅ Code splitting (Vite automatic)

### Backend
- ✅ Granian ASGI (2x faster than uvicorn)
- ✅ Async file operations (aiofiles)
- ✅ Connection pooling
- ✅ Efficient logging (enqueue=True)

## Security Considerations

1. **File Upload**
   - Content-type validation
   - Temporary file handling
   - Automatic cleanup

2. **API**
   - CORS configuration
   - Error message sanitization
   - Rate limiting ready

3. **PWA**
   - HTTPS only (Caddy)
   - Secure headers
   - No sensitive data in localStorage

## Deployment

### Development
```bash
# Terminal 1
cd backend && uv run python app.py

# Terminal 2
cd frontend && pnpm dev
```

### Production
```bash
docker-compose up -d
```

### Scaling
- Add more Granian workers
- Load balance with Caddy
- Separate database layer (if needed)

---

Architecture designed for:
✅ Performance
✅ Reliability
✅ Maintainability
✅ Developer Experience
✅ ZeroOps
