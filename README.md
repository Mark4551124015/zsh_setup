# zsh-setup

English | [简体中文](README_zh.md)

Set up a zsh environment on Linux or macOS with one script: zsh, oh-my-zsh,
powerlevel10k, plugins, and custom commands. The script can be run repeatedly;
components that are already installed are skipped.

## What's included

- **zsh**: installed using your system package manager (apt / dnf / yum / pacman / brew).
- **oh-my-zsh**: unattended installation without launching zsh or replacing your existing `.zshrc`.
- **[powerlevel10k](https://github.com/romkatv/powerlevel10k)** theme.
- **Plugins**: `git` (bundled with oh-my-zsh), `zsh-autosuggestions`, and `zsh-syntax-highlighting`.
- **Custom commands** in `functions.zsh`, automatically loaded from `$ZSH_CUSTOM` by oh-my-zsh:
  - `vpn`: enable the local proxy (SOCKS5h for `ALL_PROXY`, HTTP for HTTP/HTTPS) at `127.0.0.1:7897`.
  - `quiteVPN`: enable the local HTTP proxy silently, suitable for scripts.
  - `unvpn`: disable the proxy.
- Set zsh as the default shell using `chsh`.

## Usage

### Option 1: Remote installation

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Mark4551124015/zsh_setup/main/install.sh)"
```

Use `bash -c`, not `sh -c`: this script uses Bash features such as arrays.
On many Linux distributions, `sh` is dash and cannot run this script.

This command downloads the script before executing it. Review
[install.sh](./install.sh) before running it for the first time.

### Option 2: Clone and run locally

```bash
git clone https://github.com/Mark4551124015/zsh_setup.git
cd zsh_setup
./install.sh
```

After installation:

```bash
exec zsh           # Or open a new terminal
p10k configure     # Runs automatically on first launch; rerun it whenever needed
```

Install a **Nerd Font**, such as MesloLGS NF, and select it in your terminal settings
so the theme's icons display correctly. See the
[powerlevel10k font guide](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k).

## Proxy address

The project's default proxy address is `127.0.0.1:7897`. These commands configure
proxy environment variables; a local proxy service must be running separately.
If your proxy uses a different port, edit the installed file:

```bash
$EDITOR "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/functions.zsh"
```

## Adding custom commands

Create or edit any `*.zsh` file under `$ZSH_CUSTOM/`. oh-my-zsh loads these files
at startup, so no additional `source` command is needed in `.zshrc`.
