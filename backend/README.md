# RESIDUAL backend

本目录是 SAVE_03 的服务端安全边界。Godot 客户端不持有 RouterBase
凭据；核心流程和结局始终由本地规则决定。

## 本地运行

```powershell
npm install
npm test
npm run dev
```

默认监听 `127.0.0.1:8787`：

- `GET /health`
- `POST /v1/save-decision`

配置 `ROUTERBASE_API_KEY` 后，服务通过 RouterBase 的 OpenAI 兼容
`/v1/chat/completions` 接口请求结构化决策。模型、基础 URL 和 5 秒
总超时预算均可通过 `.env` 配置。

没有 Token、断网、超时、HTTP 错误、非法 JSON 或白名单越权时，服务
立即使用确定性的本地 fallback，游戏主线不依赖网络。

官方接口资料：

- <https://docs.routerbase.com/api-reference/chat-completions>
- <https://docs.routerbase.com/essentials/errors>
