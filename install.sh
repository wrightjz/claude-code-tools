#!/bin/bash
#
# Claude Code Dev Tools Installer
#
# This script installs Claude Code and sets up the development tools.
# After running this script, open Claude Code and run /setup to complete configuration.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/wrightjz/claude-code-tools/main/install.sh | bash
#   or
#   ./install.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Symbols
CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
ARROW="${BLUE}→${NC}"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}            Claude Code Dev Tools Installer                     ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print step
step() {
    echo -e "${ARROW} $1"
}

# Function to print success
success() {
    echo -e "  ${CHECK} $1"
}

# Function to print warning
warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

# Function to print error and exit
error() {
    echo -e "  ${CROSS} $1"
    exit 1
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)    OS="macos";;
        Linux*)     OS="linux";;
        MINGW*|MSYS*|CYGWIN*) OS="windows";;
        *)          OS="unknown";;
    esac
    echo $OS
}

OS=$(detect_os)
step "Detected OS: $OS"

# Check for required tools
step "Checking prerequisites..."

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        success "Node.js $(node -v) installed"
    else
        error "Node.js 18+ required, found $(node -v). Please upgrade: https://nodejs.org/"
    fi
else
    error "Node.js not found. Please install Node.js 18+: https://nodejs.org/"
fi

# Check npm
if command -v npm &> /dev/null; then
    success "npm $(npm -v) installed"
else
    error "npm not found. Please install Node.js which includes npm."
fi

# Check Git
if command -v git &> /dev/null; then
    success "Git $(git --version | cut -d' ' -f3) installed"
else
    error "Git not found. Please install Git: https://git-scm.com/"
fi

echo ""

# Install Claude Code
step "Installing Claude Code..."

if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
    warn "Claude Code already installed (version: $CLAUDE_VERSION)"
    read -p "    Reinstall/update? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        npm install -g @anthropic-ai/claude-code
        success "Claude Code updated"
    else
        success "Keeping existing Claude Code installation"
    fi
else
    npm install -g @anthropic-ai/claude-code
    success "Claude Code installed"
fi

echo ""

# Create Claude directories
step "Creating Claude Code configuration directories..."

mkdir -p ~/.claude/agents
mkdir -p ~/.claude/commands
mkdir -p ~/.claude/rules
mkdir -p ~/.claude/skills
success "Created ~/.claude/agents/"
success "Created ~/.claude/commands/"
success "Created ~/.claude/rules/"
success "Created ~/.claude/skills/"

echo ""

# Determine script location and repo path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're running from within the repo
if [ -f "$SCRIPT_DIR/commands/setup.md" ] || [ -f "$SCRIPT_DIR/commands/create-prd.md" ]; then
    REPO_DIR="$SCRIPT_DIR"
    success "Running from claude-code-tools repository"
else
    # We need to clone the repo
    step "Cloning claude-code-tools repository..."

    TEMP_DIR=$(mktemp -d)

    # Update this URL to your public repo
    if git clone --depth 1 https://github.com/wrightjz/claude-code-tools.git "$TEMP_DIR/claude-code-tools" 2>/dev/null; then
        REPO_DIR="$TEMP_DIR/claude-code-tools"
        success "Repository cloned to temporary directory"
    else
        error "Could not clone repository. Please clone manually and run install.sh from there."
    fi
fi

# Copy agents
step "Installing agents..."
if [ -d "$REPO_DIR/agents" ]; then
    cp "$REPO_DIR/agents/"*.md ~/.claude/agents/ 2>/dev/null || true
    AGENT_COUNT=$(ls -1 ~/.claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
    success "Installed $AGENT_COUNT agents"
else
    warn "No agents directory found"
fi

# Copy commands
step "Installing commands..."
if [ -d "$REPO_DIR/commands" ]; then
    cp "$REPO_DIR/commands/"*.md ~/.claude/commands/ 2>/dev/null || true
    CMD_COUNT=$(ls -1 ~/.claude/commands/*.md 2>/dev/null | wc -l | tr -d ' ')
    success "Installed $CMD_COUNT commands"
else
    warn "No commands directory found"
fi

# Copy rules
step "Installing rules..."
if [ -d "$REPO_DIR/rules" ]; then
    cp "$REPO_DIR/rules/"*.md ~/.claude/rules/ 2>/dev/null || true
    RULE_COUNT=$(ls -1 ~/.claude/rules/*.md 2>/dev/null | wc -l | tr -d ' ')
    success "Installed $RULE_COUNT rules"
else
    warn "No rules directory found"
fi

# Copy skills
step "Installing skills..."
if [ -d "$REPO_DIR/skills" ]; then
    cp -r "$REPO_DIR/skills/"* ~/.claude/skills/ 2>/dev/null || true
    success "Installed skills"
else
    warn "No skills directory found"
fi

# Copy hooks (optional)
if [ -d "$REPO_DIR/hooks" ]; then
    step "Installing hooks..."
    mkdir -p ~/.claude/hooks
    cp "$REPO_DIR/hooks/"* ~/.claude/hooks/ 2>/dev/null || true
    success "Installed hooks"
fi

echo ""

# Final instructions
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                 Installation Complete!                         ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Installed components:"
echo -e "  • ${BLUE}Agents${NC}: Specialized AI assistants (planner, architect, etc.)"
echo -e "  • ${BLUE}Commands${NC}: Slash commands (/create-prd, /refactor-clean, etc.)"
echo -e "  • ${BLUE}Rules${NC}: Coding standards and best practices"
echo -e "  • ${BLUE}Skills${NC}: Advanced capabilities (codemap generation)"
echo -e "  • ${BLUE}Hooks${NC}: Safety guards (blocks dangerous commands)"
echo ""
echo -e "Next steps:"
echo ""
echo -e "  ${BLUE}1.${NC} Open a terminal and run:"
echo -e "     ${YELLOW}claude${NC}"
echo ""
echo -e "  ${BLUE}2.${NC} Complete first-time authentication (browser will open)"
echo ""
echo -e "  ${BLUE}3.${NC} Start using the tools:"
echo -e "     ${YELLOW}/create-prd \"my new feature\"${NC}"
echo -e "     ${YELLOW}/refactor-clean${NC}"
echo ""
echo -e "For full documentation, see:"
echo -e "  ${BLUE}$REPO_DIR/README.md${NC}"
echo ""
