# RouterBase 快速设置指南

## 🚀 5分钟快速设置

### 第1步：获取 API Key (2分钟)
1. 访问：https://routerbase.com/api-keys
2. 注册/登录（使用 Vibe Jam 活动邮箱获得福利额度）
3. 创建 API Key
4. 复制 API Key（格式：`rb_xxxxx`）

### 第2步：配置环境变量 (1分钟)
编辑 `backend/.env` 文件，将 API Key 粘贴到对应位置：

```env
ROUTERBASE_API_KEY=rb_你的实际API密钥
```

### 第3步：测试连接 (2分钟)
```bash
cd backend
npm run test:routerbase
```

如果看到 "✅ RouterBase 连接成功!"，说明配置完成！

## 📋 检查清单

- [ ] 已访问 https://routerbase.com/api-keys
- [ ] 已创建 API Key
- [ ] 已复制 API Key
- [ ] 已编辑 `backend/.env` 文件
- [ ] 已运行 `npm run test:routerbase`
- [ ] 看到连接成功消息

## 🔧 遇到问题？

### API Key 无效
- 检查是否完整复制了 API Key（没有多余空格）
- 确认 API Key 没有过期

### 网络连接失败
- 检查网络连接
- 确认 RouterBase 服务可用
- 尝试增加超时时间：编辑 `.env` 中的 `ROUTERBASE_TIMEOUT_MS=10000`

### 额度不足
- 登录 RouterBase 后台查看余额
- Vibe Jam 参与者应该有 $20 额度
- 确认使用的是正确的账户

## 📖 详细文档

完整设置指南：`docs/ROUTERBASE_SETUP.md`

## 🎯 下一步

连接成功后：
1. 启动游戏测试 AI 功能
2. 体验 SAVE_03 的智能对话
3. 准备现场演示

---

*有问题？查看详细文档或检查后端日志*