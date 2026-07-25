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

T3.1 只返回确定性的本地 fallback。RouterBase 网络适配器将在 T3.2
接入，服务在无 Token 或断网时仍必须可用。
