#!/usr/bin/env bash
#
# Set up zsh, oh-my-zsh, powerlevel10k, plugins, and custom commands
# Supports Linux (apt/dnf/yum/pacman) and macOS (brew)
# Safe to rerun: already installed components are skipped
#
if [ -z "${BASH_VERSION:-}" ]; then
  echo "Run this script with bash (not sh), for example:" >&2
  echo '  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Mark4551124015/zsh_setup/main/install.sh)"' >&2
  exit 1
fi

set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/Mark4551124015/zsh_setup/main"

# Local installations use functions.zsh from the same directory.
# Remote installations download functions.zsh from GitHub below.
LOCAL_FUNCTIONS=""
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  _src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"
  if [[ -n "$_src_dir" && -f "$_src_dir/functions.zsh" ]]; then
    LOCAL_FUNCTIONS="$_src_dir/functions.zsh"
  fi
fi

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m[ OK ]\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }

# ---------- 1. Detect the operating system and package manager ----------
OS="$(uname -s)"

install_pkg() {
  # Install missing command-line tools (zsh / git / curl)
  local pkgs=("$@")
  if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
      info "Homebrew not found; installing..."
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
    warn "Unknown package manager. Install these packages manually: ${pkgs[*]}"
    exit 1
  fi
}

# ---------- 2. Install zsh / git / curl ----------
for bin in zsh git curl; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    info "Installing $bin ..."
    install_pkg "$bin"
  else
    ok "$bin is already installed"
  fi
done

# ---------- 3. Install oh-my-zsh ----------
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
if [[ -d "$ZSH" ]]; then
  ok "oh-my-zsh is already installed; skipping"
else
  info "Installing oh-my-zsh ..."
  KEEP_ZSHRC=yes RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
mkdir -p "$ZSH_CUSTOM/themes" "$ZSH_CUSTOM/plugins"

# ---------- 4. Install powerlevel10k ----------
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
if [[ -d "$P10K_DIR" ]]; then
  ok "powerlevel10k is already installed; skipping"
else
  info "Installing powerlevel10k ..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# ---------- 5. Install plugins: zsh-autosuggestions, zsh-syntax-highlighting ----------
AUTOSUGGESTIONS_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
if [[ -d "$AUTOSUGGESTIONS_DIR" ]]; then
  ok "zsh-autosuggestions is already installed; skipping"
else
  info "Installing zsh-autosuggestions ..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
fi

SYNTAX_HL_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
if [[ -d "$SYNTAX_HL_DIR" ]]; then
  ok "zsh-syntax-highlighting is already installed; skipping"
else
  info "Installing zsh-syntax-highlighting ..."
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$SYNTAX_HL_DIR"
fi

# ---------- 6. Install custom functions (vpn / quiteVPN / unvpn) ----------
if [[ -n "$LOCAL_FUNCTIONS" ]]; then
  cp -f "$LOCAL_FUNCTIONS" "$ZSH_CUSTOM/functions.zsh"
else
  info "Remote installation: downloading functions.zsh from GitHub ..."
  curl -fsSL "$REPO_RAW/functions.zsh" -o "$ZSH_CUSTOM/functions.zsh"
fi
ok "Custom commands installed in $ZSH_CUSTOM/functions.zsh (loaded automatically by oh-my-zsh)"

# ---------- 7. Configure ~/.zshrc ----------
ZSHRC="$HOME/.zshrc"
[[ -f "$ZSHRC" ]] || touch "$ZSHRC"

set_zshrc_var() {
  # set_zshrc_var VAR_NAME "new line content"
  local var="$1" line="$2"
  if grep -qE "^${var}=" "$ZSHRC"; then
    # Use a backup suffix for cross-platform sed -i compatibility
    sed -i.bak -E "s|^${var}=.*|${line}|" "$ZSHRC" && rm -f "$ZSHRC.bak"
  else
    printf '%s\n' "$line" >> "$ZSHRC"
  fi
}

# Existing .zshrc files may not come from the oh-my-zsh template.
# Add export ZSH if missing so the source command can locate oh-my-zsh.
if ! grep -qE '^export ZSH=' "$ZSHRC"; then
  sed -i.bak "1i export ZSH=\"\$HOME/.oh-my-zsh\"" "$ZSHRC" && rm -f "$ZSHRC.bak"
fi

set_zshrc_var "ZSH_THEME" 'ZSH_THEME="powerlevel10k/powerlevel10k"'
set_zshrc_var "plugins"   'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)'

# Load oh-my-zsh after configuring ZSH_THEME and plugins.
# KEEP_ZSHRC=yes preserves existing .zshrc files, so explicitly add the
# source command if the installer did not provide one.
if ! grep -qF 'source $ZSH/oh-my-zsh.sh' "$ZSHRC"; then
  printf '\nsource $ZSH/oh-my-zsh.sh\n' >> "$ZSHRC"
fi
ok "Configured ZSH_THEME / plugins and ensured oh-my-zsh.sh is loaded"

# ---------- 8. Set the default shell ----------
ZSH_BIN="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_BIN" ]]; then
  info "Changing the default shell to zsh (you may be prompted for a password) ..."
  if ! grep -qxF "$ZSH_BIN" /etc/shells 2>/dev/null; then
    echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "$ZSH_BIN" "$USER" || warn "chsh failed. Run manually: chsh -s $ZSH_BIN"
else
  ok "The default shell is already zsh"
fi

echo
ok "Installation complete!"
cat <<EOF

Next steps:
  1. Open a new terminal, or run: exec zsh
  2. The powerlevel10k setup wizard starts on first launch; rerun it with: p10k configure
  3. Install a Nerd Font (such as MesloLGS NF) and select it in your terminal for correct icons:
     https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k
  4. Available commands: vpn / quiteVPN / unvpn (local proxy port: 7897; edit $ZSH_CUSTOM/functions.zsh as needed)

EOF
