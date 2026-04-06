#!/bin/bash

#==============================================================================
# ICER Skill Package Installer
# 版本: 1.1.0
# 用途: 安装集成电路工程技能包到 Claude Code
#==============================================================================

set -e

# 版本信息
VERSION="1.1.0"
ICER_DIR=$(dirname "$0")
CLAUDE_HOME=~/.claude

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#------------------------------------------------------------------------------
# 帮助信息
#------------------------------------------------------------------------------

show_help() {
    echo "======================================"
    echo "ICER Skill Package Installer v${VERSION}"
    echo "======================================"
    echo ""
    echo "用法: ./install.sh <命令>"
    echo ""
    echo "命令:"
    echo "  all        安装所有组件 (rules + skills + agents + examples + references)"
    echo "  rules      仅安装规则"
    echo "  skills     仅安装技能"
    echo "  agents     仅安装代理"
    echo "  examples   仅安装示例代码"
    echo "  references 仅安装参考文档"
    echo "  update     更新到最新版本"
    echo "  uninstall  卸载已安装的组件"
    echo "  verify     验证安装"
    echo "  version    显示版本信息"
    echo "  help       显示此帮助"
    echo ""
}

#------------------------------------------------------------------------------
# 检查依赖
#------------------------------------------------------------------------------

check_dependencies() {
    echo -e "${BLUE}检查依赖...${NC}"

    # 检查 Claude Code 是否安装
    if [ ! -d "$CLAUDE_HOME" ]; then
        echo -e "${YELLOW}警告: 未找到 Claude Code 配置目录${NC}"
        echo -e "${YELLOW}将创建目录: $CLAUDE_HOME${NC}"
        mkdir -p "$CLAUDE_HOME"
    fi

    echo -e "${GREEN}✓ 依赖检查通过${NC}"
}

#------------------------------------------------------------------------------
# 安装规则
#------------------------------------------------------------------------------

install_rules() {
    echo -e "${BLUE}安装规则...${NC}"

    mkdir -p "$CLAUDE_HOME/rules"

    # 安装通用规则
    if [ -d "$ICER_DIR/rules/common" ]; then
        cp -r "$ICER_DIR/rules/common" "$CLAUDE_HOME/rules/"
        echo -e "${GREEN}✓ 通用规则已安装${NC}"
    fi

    # 安装 IC 特定规则
    if [ -d "$ICER_DIR/rules/ic" ]; then
        cp -r "$ICER_DIR/rules/ic" "$CLAUDE_HOME/rules/"
        echo -e "${GREEN}✓ IC 特定规则已安装${NC}"
    fi

    # 安装规则 README
    if [ -f "$ICER_DIR/rules/README.md" ]; then
        cp "$ICER_DIR/rules/README.md" "$CLAUDE_HOME/rules/"
    fi
}

#------------------------------------------------------------------------------
# 安装技能
#------------------------------------------------------------------------------

install_skills() {
    echo -e "${BLUE}安装技能...${NC}"

    mkdir -p "$CLAUDE_HOME/skills"

    if [ -d "$ICER_DIR/skills" ]; then
        cp -r "$ICER_DIR/skills/"* "$CLAUDE_HOME/skills/"

        # 统计安装的技能数量
        SKILL_COUNT=$(find "$ICER_DIR/skills" -name "SKILL.md" | wc -l)
        echo -e "${GREEN}✓ 已安装 $SKILL_COUNT 个技能${NC}"
    fi
}

#------------------------------------------------------------------------------
# 安装代理
#------------------------------------------------------------------------------

install_agents() {
    echo -e "${BLUE}安装代理...${NC}"

    mkdir -p "$CLAUDE_HOME/agents"

    if [ -d "$ICER_DIR/agents" ]; then
        cp -r "$ICER_DIR/agents/"* "$CLAUDE_HOME/agents/"

        # 统计安装的代理数量
        AGENT_COUNT=$(find "$ICER_DIR/agents" -name "AGENT.md" | wc -l)
        echo -e "${GREEN}✓ 已安装 $AGENT_COUNT 个代理${NC}"
    fi
}

#------------------------------------------------------------------------------
# 安装示例代码
#------------------------------------------------------------------------------

install_examples() {
    echo -e "${BLUE}安装示例代码...${NC}"

    mkdir -p "$CLAUDE_HOME/examples"

    if [ -d "$ICER_DIR/examples" ]; then
        cp -r "$ICER_DIR/examples/"* "$CLAUDE_HOME/examples/"

        # 统计文件数量
        FILE_COUNT=$(find "$ICER_DIR/examples" -type f | wc -l)
        echo -e "${GREEN}✓ 已安装 $FILE_COUNT 个示例文件${NC}"
    fi
}

#------------------------------------------------------------------------------
# 安装参考文档
#------------------------------------------------------------------------------

install_references() {
    echo -e "${BLUE}安装参考文档...${NC}"

    mkdir -p "$CLAUDE_HOME/references"

    if [ -d "$ICER_DIR/references" ]; then
        cp -r "$ICER_DIR/references/"* "$CLAUDE_HOME/references/"

        # 统计文件数量
        FILE_COUNT=$(find "$ICER_DIR/references" -name "*.md" | wc -l)
        echo -e "${GREEN}✓ 已安装 $FILE_COUNT 个参考文档${NC}"
    fi
}

#------------------------------------------------------------------------------
# 安装所有组件
#------------------------------------------------------------------------------

install_all() {
    echo "======================================"
    echo "ICER Skill Package Installer v${VERSION}"
    echo "======================================"
    echo ""

    check_dependencies

    install_rules
    install_skills
    install_agents
    install_examples
    install_references

    # 创建版本文件
    echo "$VERSION" > "$CLAUDE_HOME/.icer_version"

    echo ""
    echo "======================================"
    echo -e "${GREEN}✓ ICER Skill Package v${VERSION} 安装完成!${NC}"
    echo "======================================"
    echo ""
    echo "下一步:"
    echo "1. 重启 Claude Code 会话"
    echo "2. 尝试: /skill rtl-coding"
    echo "3. 尝试: /agent rtl-designer"
    echo "4. 查看示例: ~/.claude/examples/"
    echo "5. 查看参考: ~/.claude/references/"
    echo ""
}

#------------------------------------------------------------------------------
# 更新
#------------------------------------------------------------------------------

update() {
    echo -e "${BLUE}更新 ICER Skill Package...${NC}"

    # 检查当前版本
    if [ -f "$CLAUDE_HOME/.icer_version" ]; then
        CURRENT_VERSION=$(cat "$CLAUDE_HOME/.icer_version")
        echo -e "${YELLOW}当前版本: $CURRENT_VERSION${NC}"
    fi

    # 检查 git
    if [ -d "$ICER_DIR/.git" ]; then
        echo -e "${BLUE}从 Git 仓库更新...${NC}"
        cd "$ICER_DIR"
        git pull
        cd - > /dev/null
    fi

    # 重新安装
    install_all
}

#------------------------------------------------------------------------------
# 卸载
#------------------------------------------------------------------------------

uninstall() {
    echo -e "${YELLOW}卸载 ICER Skill Package...${NC}"

    read -p "确定要卸载吗? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "取消卸载"
        exit 0
    fi

    # 删除规则
    if [ -d "$CLAUDE_HOME/rules/common" ]; then
        rm -rf "$CLAUDE_HOME/rules/common"
        echo -e "${GREEN}✓ 已删除通用规则${NC}"
    fi

    if [ -d "$CLAUDE_HOME/rules/ic" ]; then
        rm -rf "$CLAUDE_HOME/rules/ic"
        echo -e "${GREEN}✓ 已删除 IC 特定规则${NC}"
    fi

    # 删除技能
    if [ -d "$CLAUDE_HOME/skills" ]; then
        # 只删除 ICER 相关的技能
        for skill in architecture-design rtl-coding systemverilog uvvm-verification \
                     assertion-based-verification physical-design timing-analysis \
                     power-analysis functional-safety-analysis board-bringup \
                     eda-scripting drc-lvs-debug; do
            if [ -d "$CLAUDE_HOME/skills/$skill" ]; then
                rm -rf "$CLAUDE_HOME/skills/$skill"
            fi
        done
        echo -e "${GREEN}✓ 已删除技能${NC}"
    fi

    # 删除代理
    if [ -d "$CLAUDE_HOME/agents" ]; then
        # 只删除 ICER 相关的代理
        for agent in chip-architect rtl-designer verification-engineer \
                     physical-design-engineer timing-engineer power-engineer \
                     functional-safety-engineer validation-engineer \
                     drc-engineer eda-automation-engineer; do
            if [ -d "$CLAUDE_HOME/agents/$agent" ]; then
                rm -rf "$CLAUDE_HOME/agents/$agent"
            fi
        done
        echo -e "${GREEN}✓ 已删除代理${NC}"
    fi

    # 删除示例
    if [ -d "$CLAUDE_HOME/examples" ]; then
        rm -rf "$CLAUDE_HOME/examples"
        echo -e "${GREEN}✓ 已删除示例${NC}"
    fi

    # 删除参考文档
    if [ -d "$CLAUDE_HOME/references" ]; then
        rm -rf "$CLAUDE_HOME/references"
        echo -e "${GREEN}✓ 已删除参考文档${NC}"
    fi

    # 删除版本文件
    if [ -f "$CLAUDE_HOME/.icer_version" ]; then
        rm -f "$CLAUDE_HOME/.icer_version"
    fi

    echo -e "${GREEN}✓ 卸载完成${NC}"
}

#------------------------------------------------------------------------------
# 验证安装
#------------------------------------------------------------------------------

verify() {
    echo -e "${BLUE}验证 ICER Skill Package 安装...${NC}"
    echo ""

    ERROR_COUNT=0

    # 检查规则
    if [ -d "$CLAUDE_HOME/rules/common" ] && [ -d "$CLAUDE_HOME/rules/ic" ]; then
        RULES_COUNT=$(find "$CLAUDE_HOME/rules" -name "*.md" | wc -l)
        echo -e "${GREEN}✓ 规则已安装 ($RULES_COUNT 个文件)${NC}"
    else
        echo -e "${RED}✗ 规则未正确安装${NC}"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    # 检查技能
    if [ -d "$CLAUDE_HOME/skills" ]; then
        SKILL_COUNT=$(find "$CLAUDE_HOME/skills" -name "SKILL.md" | wc -l)
        if [ "$SKILL_COUNT" -ge 12 ]; then
            echo -e "${GREEN}✓ 技能已安装 ($SKILL_COUNT 个)${NC}"
        else
            echo -e "${YELLOW}⚠ 技能安装不完整 ($SKILL_COUNT 个，期望 12 个)${NC}"
        fi
    else
        echo -e "${RED}✗ 技能未安装${NC}"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    # 检查代理
    if [ -d "$CLAUDE_HOME/agents" ]; then
        AGENT_COUNT=$(find "$CLAUDE_HOME/agents" -name "AGENT.md" | wc -l)
        if [ "$AGENT_COUNT" -ge 10 ]; then
            echo -e "${GREEN}✓ 代理已安装 ($AGENT_COUNT 个)${NC}"
        else
            echo -e "${YELLOW}⚠ 代理安装不完整 ($AGENT_COUNT 个，期望 10 个)${NC}"
        fi
    else
        echo -e "${RED}✗ 代理未安装${NC}"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    # 检查示例
    if [ -d "$CLAUDE_HOME/examples" ]; then
        EXAMPLE_COUNT=$(find "$CLAUDE_HOME/examples" -type f | wc -l)
        echo -e "${GREEN}✓ 示例已安装 ($EXAMPLE_COUNT 个文件)${NC}"
    else
        echo -e "${YELLOW}⚠ 示例未安装${NC}"
    fi

    # 检查参考文档
    if [ -d "$CLAUDE_HOME/references" ]; then
        REF_COUNT=$(find "$CLAUDE_HOME/references" -name "*.md" | wc -l)
        echo -e "${GREEN}✓ 参考文档已安装 ($REF_COUNT 个文件)${NC}"
    else
        echo -e "${YELLOW}⚠ 参考文档未安装${NC}"
    fi

    # 检查版本
    if [ -f "$CLAUDE_HOME/.icer_version" ]; then
        INSTALLED_VERSION=$(cat "$CLAUDE_HOME/.icer_version")
        echo -e "${GREEN}✓ 版本: $INSTALLED_VERSION${NC}"
    fi

    echo ""

    if [ "$ERROR_COUNT" -eq 0 ]; then
        echo -e "${GREEN}✓ 验证通过${NC}"
        exit 0
    else
        echo -e "${RED}✗ 验证失败，发现 $ERROR_COUNT 个错误${NC}"
        echo -e "${YELLOW}请重新运行: ./install.sh all${NC}"
        exit 1
    fi
}

#------------------------------------------------------------------------------
# 显示版本
#------------------------------------------------------------------------------

show_version() {
    echo "ICER Skill Package v${VERSION}"

    if [ -f "$CLAUDE_HOME/.icer_version" ]; then
        INSTALLED_VERSION=$(cat "$CLAUDE_HOME/.icer_version")
        echo "已安装版本: $INSTALLED_VERSION"
    else
        echo "未检测到已安装版本"
    fi
}

#------------------------------------------------------------------------------
# 主程序
#------------------------------------------------------------------------------

case "$1" in
    all)
        install_all
        ;;
    rules)
        check_dependencies
        install_rules
        ;;
    skills)
        check_dependencies
        install_skills
        ;;
    agents)
        check_dependencies
        install_agents
        ;;
    examples)
        check_dependencies
        install_examples
        ;;
    references)
        check_dependencies
        install_references
        ;;
    update)
        update
        ;;
    uninstall)
        uninstall
        ;;
    verify)
        verify
        ;;
    version)
        show_version
        ;;
    help)
        show_help
        ;;
    *)
        echo -e "${RED}错误: 未知命令 '$1'${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac

exit 0
