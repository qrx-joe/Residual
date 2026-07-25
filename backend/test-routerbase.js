#!/usr/bin/env node

/**
 * RouterBase 连接测试脚本
 * 用于验证 API Key 配置和网络连接
 */

import { loadServerConfig } from './dist/config.js';
import https from 'https';

async function testRouterBaseConnection() {
  console.log('🔍 测试 RouterBase 连接...\n');

  // 检查环境变量
  console.log('📋 配置检查:');
  console.log(`  API Key: ${config.ROUTERBASE_API_KEY ? '✅ 已设置' : '❌ 未设置'}`);
  console.log(`  Base URL: ${config.ROUTERBASE_BASE_URL}`);
  console.log(`  Model: ${config.ROUTERBASE_MODEL}`);
  console.log(`  Timeout: ${config.ROUTERBASE_TIMEOUT_MS}ms\n`);

  if (!config.ROUTERBASE_API_KEY || config.ROUTERBASE_API_KEY === 'YOUR_ROUTERBASE_API_KEY_HERE') {
    console.error('❌ 错误: 请先设置有效的 ROUTERBASE_API_KEY');
    console.log('💡 提示: 请访问 https://routerbase.com/api-keys 获取 API Key');
    console.log('📖 指南: 查看 docs/ROUTERBASE_SETUP.md 获取详细说明\n');
    process.exit(1);
  }

  // 测试简单的 API 调用
  console.log('🌐 测试 API 连接...');

  const testData = {
    model: config.ROUTERBASE_MODEL,
    messages: [
      {
        role: 'user',
        content: 'Hello! This is a test message from RESIDUAL game.'
      }
    ],
    max_tokens: 10
  };

  const url = new URL(`${config.ROUTERBASE_BASE_URL}/chat/completions`);

  const options = {
    hostname: url.hostname,
    port: 443,
    path: url.pathname + url.search,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${config.ROUTERBASE_API_KEY}`,
      'Content-Length': Buffer.byteLength(JSON.stringify(testData))
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        if (res.statusCode === 200) {
          console.log('✅ RouterBase 连接成功!\n');
          try {
            const response = JSON.parse(data);
            console.log('📝 API 响应示例:');
            console.log(JSON.stringify(response, null, 2).substring(0, 200) + '...\n');
            console.log('🎉 配置完成，可以开始使用 RouterBase 服务!');
          } catch (e) {
            console.log('📝 原始响应:', data.substring(0, 200));
          }
          resolve(true);
        } else {
          console.error(`❌ API 调用失败: HTTP ${res.statusCode}`);
          console.error('📝 错误详情:', data.substring(0, 200));
          reject(new Error(`HTTP ${res.statusCode}`));
        }
      });
    });

    req.on('error', (error) => {
      console.error('❌ 网络错误:', error.message);
      console.log('💡 请检查:');
      console.log('  1. 网络连接是否正常');
      console.log('  2. RouterBase 服务是否可用');
      console.log('  3. API Key 是否正确');
      reject(error);
    });

    req.setTimeout(config.ROUTERBASE_TIMEOUT_MS, () => {
      req.destroy();
      console.error(`❌ 请求超时 (${config.ROUTERBASE_TIMEOUT_MS}ms)`);
      console.log('💡 建议: 增加 ROUTERBASE_TIMEOUT_MS 的值或检查网络连接');
      reject(new Error('Timeout'));
    });

    req.write(JSON.stringify(testData));
    req.end();
  });
}

// 运行测试
if (require.main === module) {
  testRouterBaseConnection()
    .then(() => {
      console.log('\n✨ 测试完成!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('\n❌ 测试失败:', error.message);
      console.log('\n📖 获取帮助: docs/ROUTERBASE_SETUP.md');
      process.exit(1);
    });
}

module.exports = { testRouterBaseConnection };