#!/bin/bash

set -e

ICER_DIR=$(dirname "$0")
CLAUDE_HOME=~/.claude

echo "======================================"
echo "ICER Skill Package Installer"
echo "======================================"

install_rules() {
    echo "Installing rules..."
    mkdir -p "$CLAUDE_HOME/rules"
    cp -r "$ICER_DIR/rules/"* "$CLAUDE_HOME/rules/"
    echo "✓ Rules installed to $CLAUDE_HOME/rules/"
}

install_skills() {
    echo "Installing skills..."
    mkdir -p "$CLAUDE_HOME/skills"
    cp -r "$ICER_DIR/skills/"* "$CLAUDE_HOME/skills/"
    echo "✓ Skills installed to $CLAUDE_HOME/skills/"
}

install_agents() {
    echo "Installing agents..."
    mkdir -p "$CLAUDE_HOME/agents"
    cp -r "$ICER_DIR/agents/"* "$CLAUDE_HOME/agents/"
    echo "✓ Agents installed to $CLAUDE_HOME/agents/"
}

install_all() {
    install_rules
    install_skills
    install_agents
    echo ""
    echo "======================================"
    echo "✓ ICER Skill Package installed complete!"
    echo "======================================"
    echo ""
    echo "Next steps:"
    echo "1. Restart your Claude Code session"
    echo "2. Try: /skill rtl-coding"
    echo "3. Try: /agent rtl-designer"
    echo ""
}

show_help() {
    echo "Usage: ./install.sh <component>"
    echo ""
    echo "Components:"
    echo "  all      - Install everything (rules + skills + agents)"
    echo "  rules    - Install rules only"
    echo "  skills   - Install skills only"
    echo "  agents   - Install agents only"
    echo "  help     - Show this help"
    echo ""
}

case "$1" in
    all)
        install_all
        ;;
    rules)
        install_rules
        ;;
    skills)
        install_skills
        ;;
    agents)
        install_agents
        ;;
    help)
        show_help
        ;;
    *)
        echo "Error: Unknown component '$1'"
        echo ""
        show_help
        exit 1
        ;;
esac

exit 0
