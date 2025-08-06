#!/bin/bash
set -e

# Gemini-Dev CLI - Direct GitHub Install
echo "🚀 Installing Gemini-Dev CLI from GitHub..."
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# GitHub repository
GITHUB_REPO="https://github.com/akhuang/office-cli.git"
TEMP_DIR="/tmp/gemini-dev-install-$$"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is required but not installed.${NC}"
    echo ""
    echo -e "${YELLOW}Install Node.js first:${NC}"
    echo "  macOS:    brew install node"
    echo "  Ubuntu:   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs"
    echo "  Windows:  Download from https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo -e "${RED}❌ Node.js 20+ required (current: $(node -v))${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Node.js $(node -v) detected${NC}"

# Check Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is required but not installed.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Git detected${NC}"

# Create temp directory
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo -e "${BLUE}📥 Cloning repository...${NC}"
git clone "$GITHUB_REPO" gemini-dev-cli
cd gemini-dev-cli
git checkout dev

echo -e "${BLUE}🔨 Building project...${NC}"
npm install
npm run build
npm run bundle

echo -e "${BLUE}🌍 Installing globally...${NC}"
# Create a simple global installation
sudo npm link

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✅ Gemini-Dev CLI installed successfully!${NC}"
echo ""
echo -e "${BLUE}🚀 Quick Start:${NC}"
echo "   gemini-dev -p \"Hello world\"           # One-shot command"
echo "   gemini-dev                            # Interactive mode"
echo ""
echo -e "${BLUE}⚙️  Configuration:${NC}"
echo "   Config: ~/.gemini-dev/settings.json"
echo "   Default: Ollama + qwen3:8b model"
echo ""

# Check Ollama
if command -v ollama &> /dev/null; then
    echo -e "${GREEN}✅ Ollama detected - ready for local AI!${NC}"
    if ollama list &> /dev/null; then
        MODEL_COUNT=$(ollama list | tail -n +2 | wc -l)
        if [ "$MODEL_COUNT" -gt 0 ]; then
            echo -e "${GREEN}✅ Found $MODEL_COUNT Ollama model(s)${NC}"
        else
            echo -e "${YELLOW}💡 Download a model: ollama pull qwen3:8b${NC}"
        fi
    fi
else
    echo -e "${YELLOW}💡 Install Ollama for local AI:${NC}"
    echo "   macOS:    brew install ollama"
    echo "   Linux:    curl -fsSL https://ollama.ai/install.sh | sh"
    echo "   Windows:  Visit https://ollama.ai"
fi

echo ""
echo -e "${GREEN}🎉 Installation complete! Try: gemini-dev -p \"Hello AI!\"${NC}"