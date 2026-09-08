#!/usr/bin/env bash
#
# 从 0 搭建 zsh 环境：zsh + oh-my-zsh + powerlevel10k + 插件 + 自定义命令
# 支持 Linux (apt/dnf/yum/pacman) 和 macOS (brew)
# 可重复执行（幂等）：已安装的部分会自动跳过
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m[ OK ]\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }

# ---------- 1. 识别系统 & 包管理器 ----------
OS="$(uname -s)"

install_pkg() {
  # 安装缺失的命令行工具（zsh / git / curl）
  local pkgs=("$@")
  if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
      info "未检测到 Homebrew，正在安装..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install "${pkgs[@]}"
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y
    sudo apt-get install -y "${pkgs[@]}"
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y "${pkgs[@]}"
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y "${pkgs[@]}"
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm "${pkgs[@]}"
  else
    warn "未识别的包管理器，请手动安装: ${pkgs[*]}"
    exit 1
  fi
}

# ---------- 2. 安装 zsh / git / curl ----------
for bin in zsh git curl; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    info "安装 $bin ..."
    install_pkg "$bin"
  else
    ok "$bin 已安装"
  fi
done

# ---------- 3. 安装 oh-my-zsh ----------
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
if [[ -d "$ZSH" ]]; then
  ok "oh-my-zsh 已安装，跳过"
else
  info "安装 oh-my-zsh ..."
  KEEP_ZSHRC=yes RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
mkdir -p "$ZSH_CUSTOM/themes" "$ZSH_CUSTOM/plugins"

# ---------- 4. 安装 powerlevel10k ----------
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
if [[ -d "$P10K_DIR" ]]; then
  ok "powerlevel10k 已安装，跳过"
else
  info "安装 powerlevel10k ..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# ---------- 5. 安装插件: zsh-autosuggestions, zsh-syntax-highlighting ----------
AUTOSUGGESTIONS_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
if [[ -d "$AUTOSUGGESTIONS_DIR" ]]; then
  ok "zsh-autosuggestions 已安装，跳过"
else
  info "安装 zsh-autosuggestions ..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
fi

SYNTAX_HL_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
if [[ -d "$SYNTAX_HL_DIR" ]]; then
  ok "zsh-syntax-highlighting 已安装，跳过"
else
  info "安装 zsh-syntax-highlighting ..."
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$SYNTAX_HL_DIR"
fi

# ---------- 6. 写入自定义函数 (vpn / quiteVPN / unvpn) ----------
cp -f "$SCRIPT_DIR/functions.zsh" "$ZSH_CUSTOM/functions.zsh"
ok "自定义命令已写入 $ZSH_CUSTOM/functions.zsh (oh-my-zsh 会自动加载)"

# ---------- 7. 配置 ~/.zshrc ----------
ZSHRC="$HOME/.zshrc"
[[ -f "$ZSHRC" ]] || touch "$ZSHRC"

set_zshrc_var() {
  # set_zshrc_var VAR_NAME "new line content"
  local var="$1" line="$2"
  if grep -qE "^${var}=" "$ZSHRC"; then
    # 跨平台 sed -i 兼容写法
    sed -i.bak -E "s|^${var}=.*|${line}|" "$ZSHRC" && rm -f "$ZSHRC.bak"
  else
    printf '%s\n' "$line" >> "$ZSHRC"
  fi
}

set_zshrc_var "ZSH_THEME" 'ZSH_THEME="powerlevel10k/powerlevel10k"'
set_zshrc_var "plugins"   'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)'
ok "已设置 ZSH_THEME 和 plugins"

# ---------- 8. 设为默认 shell ----------
ZSH_BIN="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_BIN" ]]; then
  info "切换默认 shell 为 zsh（可能需要输入密码）..."
  if ! grep -qxF "$ZSH_BIN" /etc/shells 2>/dev/null; then
    echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "$ZSH_BIN" "$USER" || warn "chsh 失败，请手动执行: chsh -s $ZSH_BIN"
else
  ok "默认 shell 已经是 zsh"
fi

echo
ok "全部安装完成！"
cat <<EOF

后续步骤：
  1. 打开新终端，或执行: exec zsh
  2. 首次进入会自动触发 powerlevel10k 配置向导；也可随时手动运行: p10k configure
  3. 建议安装一款 Nerd Font（如 MesloLGS NF）并在终端里选用，图标才能正常显示：
     https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k
  4. 已预设命令: vpn / quiteVPN / unvpn （开关本地 7899 端口代理，按需修改 $ZSH_CUSTOM/functions.zsh）

EOF
