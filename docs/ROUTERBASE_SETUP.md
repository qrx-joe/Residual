# RouterBase API 接入指南

## 1. 获取 RouterBase API Key

### 访问 RouterBase
打开浏览器访问：https://routerbase.com/api-keys

### 注册/登录
- 如果没有账号，先注册一个 RouterBase 账号
- 使用注册邮箱登录（记得使用 Vibe Jam 活动注册的邮箱以获得福利额度）

### 创建 API Key
1. 在 API Keys 页面点击 "Create API Key" 或 "新建 API Key"
2. 给 API Key 起一个描述性名称，比如 "RESIDUAL-Game"
3. 选择适当的权限范围（Read/Write）
4. 点击创建

### 复制 API Key
- 创建后会显示 API Key（格式通常是以 `rb_` 或 `sk-` 开头的字符串）
- **重要**：立即复制并保存，因为离开页面后可能无法再次看到完整的 Key

## 2. 配置环境变量

### 方式一：直接编辑 .env 文件
编辑 `backend/.env` 文件，将 `YOUR_ROUTERBASE_API_KEY_HERE` 替换为实际的 API Key：

```env
ROUTERBASE_API_KEY=rb_your_actual_api_key_here
```

### 方式二：通过命令行设置
在项目根目录执行：

```bash
# Windows PowerShell
cd backend
$env:ROUTERBASE_API_KEY="your_actual_api_key_here"

# Linux/Mac
export ROUTERBASE_API_KEY="your_actual_api_key_here"
```

## 3. 验证配置

### 启动后端服务
```bash
cd backend
npm install  # 如果还没有安装依赖
npm run dev
```

### 测试 API 连接
后端启动后，可以通过以下方式测试 RouterBase 连接：

```bash
# 测试健康检查
curl http://127.0.0.1:8787/health

# 测试 RouterBase 连接
curl -X POST http://127.0.0.1:8787/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "测试连接",
    "playerAction": "test"
  }'
```

## 4. Godot 客户端配置

### 配置 API 端点
在 Godot 项目中，确保 AIClient 配置指向本地后端：

```gdscript
# 在 scripts/autoload/config.gd 中
var backend_url = "http://127.0.0.1:8787"
```

### 测试游戏内 AI 功能
1. 启动 Godot 游戏
2. 进入需要 AI 回应的场景
3. 检查控制台输出，确认是否成功连接到后端
4. 验证 SAVE_03 的对话是否正常显示

## 5. 故障排除

### 常见问题

**问题**：后端启动失败，提示环境变量错误
- **解决**：检查 `.env` 文件格式，确保没有多余空格或引号

**问题**：RouterBase API 调用失败，返回 401
- **解决**：检查 API Key 是否正确复制，确保没有多余的空格

**问题**：超时错误
- **解决**：增加 `ROUTERBASE_TIMEOUT_MS` 的值，或检查网络连接

**问题**：模型不可用
- **解决**：检查 `ROUTERBASE_MODEL` 设置，确保使用 RouterBase 支持的模型

### 调试模式
如果遇到问题，可以启用调试日志：

```env
LOG_LEVEL=debug
```

## 6. 安全注意事项

### 不要提交 API Key 到 Git
确保 `.env` 文件已添加到 `.gitignore`：

```text
# .gitignore
backend/.env
```

### API Key 管理
- 不要在代码中硬编码 API Key
- 定期轮换 API Key
- 为不同环境使用不同的 API Key
- 监控 API 使用量和成本

## 7. RouterBase 福利额度

根据 Vibe Jam 活动，每个参与者应该有：
- **RouterBase**: 20 美元额度
- **Tripo**: 3000 Credits

### 检查额度
登录 RouterBase 后台查看：
- 当前余额
- 使用记录
- 有效期

### 额度使用建议
- 先用小额度测试连接和配置
- 核心功能验证后再进行完整测试
- 保留足够额度用于现场演示

## 8. 本地 Fallback

如果 RouterBase 不可用或额度用完，游戏会自动使用本地 fallback：

- **Fallback 触发条件**：
  - API Key 无效或过期
  - 网络连接失败
  - API 调用超时
  - 额度不足

- **Fallback 行为**：
  - 使用本地预定义的 SAVE_03 对话
  - 保证游戏流程完整性
  - 不影响核心玩法体验

## 9. 配置完成检查清单

- [ ] 已获取 RouterBase API Key
- [ ] 已配置 `backend/.env` 文件
- [ ] 已验证后端服务正常启动
- [ ] 已测试 API 连接成功
- [ ] Godot 游戏内 AI 功能正常
- [ ] 已确认 fallback 机制工作正常
- [ ] `.env` 文件已添加到 `.gitignore`
- [ ] 已检查 RouterBase 额度和使用情况

## 10. 下一步

配置完成后，可以：

1. **测试完整游戏流程**：体验 SAVE_03 的 AI 回应
2. **调整对话参数**：优化 AI 回应的质量和风格
3. **监控 API 使用**：确保在预算范围内
4. **准备现场演示**：确保网络连接稳定

---

*如有问题，请检查后端日志或联系技术支持。*