#!/bin/bash
set -e

# Gemini-Dev CLI - Prebuilt Installation
echo "🚀 Installing Gemini-Dev CLI (Prebuilt)..."
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Installation directory
INSTALL_DIR="$HOME/.local/bin"
GEMINI_DEV_DIR="$HOME/.gemini-dev"

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$GEMINI_DEV_DIR"

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

echo -e "${BLUE}📥 Downloading prebuilt binary...${NC}"

# Download gemini.js from GitHub
curl -fsSL "https://raw.githubusercontent.com/akhuang/office-cli/dev/bundle/gemini.js" -o "$INSTALL_DIR/gemini-dev.js"

# Make executable
chmod +x "$INSTALL_DIR/gemini-dev.js"

# Create wrapper script
cat > "$INSTALL_DIR/gemini-dev" << 'EOF'
#!/bin/bash
exec node "$HOME/.local/bin/gemini-dev.js" "$@"
EOF

chmod +x "$INSTALL_DIR/gemini-dev"

# Create default settings
if [ ! -f "$GEMINI_DEV_DIR/settings.json" ]; then
    cat > "$GEMINI_DEV_DIR/settings.json" << 'EOF'
{
  "selectedAuthType": "ollama",
  "model": "qwen3:8b"
}
EOF
    echo -e "${GREEN}✅ Created default configuration${NC}"
fi

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}⚠️  Adding ~/.local/bin to your PATH${NC}"
    
    # Add to shell profile
    if [ -n "$ZSH_VERSION" ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
        echo -e "${BLUE}Added to ~/.zshrc${NC}"
    elif [ -n "$BASH_VERSION" ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo -e "${BLUE}Added to ~/.bashrc${NC}"
    fi
    
    export PATH="$HOME/.local/bin:$PATH"
fi

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
echo -e "${GREEN}🎉 Installation complete!${NC}"
echo -e "${BLUE}💡 You may need to restart your terminal or run: source ~/.bashrc${NC}"
echo ""
echo -e "${GREEN}Try: gemini-dev -p \"Hello AI!\"${NC}"