# Gemini-Dev CLI - Installation Guide

## 🚀 One-Line Install (推荐)

```bash
curl -fsSL https://raw.githubusercontent.com/akhuang/office-cli/dev/install-from-github.sh | bash
```

这个命令会：
- ✅ 检查 Node.js (如果没有会提示安装)
- ✅ 克隆仓库到临时目录
- ✅ 构建项目
- ✅ 全局安装 `gemini-dev` 命令
- ✅ 清理临时文件

## 使用方法

安装完成后：

```bash
# 一次性命令
gemini-dev -p "写一个 Python hello world"

# 交互模式
gemini-dev

# 查看帮助
gemini-dev --help
```

## 🦙 Ollama 支持 (默认)

默认使用 Ollama 本地 AI，无需配置。

### 安装 Ollama
```bash
# macOS
brew install ollama

# Linux
curl -fsSL https://ollama.ai/install.sh | sh

# Windows - 访问 https://ollama.ai
```

### 下载模型
```bash
ollama serve              # 启动 Ollama
ollama pull qwen3:8b      # 推荐模型
```

## ⚙️ 配置

配置文件: `~/.gemini-dev/settings.json`

默认配置:
```json
{
  "selectedAuthType": "ollama",
  "model": "qwen3:8b"
}
```

## 环境变量

```bash
# 模型选择
export MODEL_NAME=qwen3:8b

# Ollama 设置
export OLLAMA_BASE_URL=http://localhost:11434

# OpenAI 兼容 API
export OPENAI_COMPATIBLE_BASE_URL=http://your-server:8000
export OPENAI_COMPATIBLE_API_KEY=sk-your-key

# Google APIs
export GEMINI_API_KEY=your-api-key
```

## 系统要求

- **Node.js**: 20.0.0 或更高
- **Git**: 任意版本
- **操作系统**: macOS, Linux, Windows (WSL)
- **内存**: 4GB+ (运行本地模型)

## 🆘 故障排除

### "Node.js not found"
```bash
# macOS
brew install node

# Ubuntu
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs

# Windows
# 访问 https://nodejs.org/
```

### "gemini-dev: command not found"
```bash
# 检查全局安装
which gemini-dev
npm list -g --depth=0 | grep gemini-dev

# 重新安装
curl -fsSL https://raw.githubusercontent.com/akhuang/office-cli/dev/install-from-github.sh | bash
```

---

**🎉 安装完成！开始使用 AI 辅助编程吧！**