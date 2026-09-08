# zsh-setup

新 Linux / macOS 主机一键搭建 zsh 环境：zsh + oh-my-zsh + powerlevel10k + 插件 + 自定义命令。
脚本幂等，重复执行安全（已装的部分自动跳过）。

## 包含内容

- **zsh**：通过系统包管理器安装（apt / dnf / yum / pacman / brew）
- **oh-my-zsh**：无人值守安装（不会自动进入 zsh、不覆盖已有 `.zshrc` 主体）
- **主题 [powerlevel10k](https://github.com/romkatv/powerlevel10k)**
- **插件**：`git`（oh-my-zsh 内置）、`zsh-autosuggestions`、`zsh-syntax-highlighting`
- **自定义命令**（`functions.zsh`，放入 `$ZSH_CUSTOM` 由 oh-my-zsh 自动加载）：
  - `vpn` — 开启代理（socks5h + http，127.0.0.1:7899）
  - `quiteVPN` — 静默开启代理（不打印提示）
  - `unvpn` — 关闭代理
- 自动将默认 shell 切换为 zsh (`chsh`)

## 使用

### 方式一：一键远程安装（新机器最快）

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Mark4551124015/zsh_setup/main/install.sh)"
```

> 注意是 `bash -c`，不是 `sh -c`：脚本用了 bash 数组等语法，`sh` 在很多发行版上是
> dash，不兼容（会报 `set: Illegal option -o pipefail` 之类的错）。
>
> 先把脚本整体下载成字符串再执行，比 `curl | bash` 更不容易因网络中断而执行到一半的
> 脚本。**建议第一次用之前自己点开 [install.sh](./install.sh) 看一眼再跑**，毕竟是从
> 网上下来直接执行的脚本。

### 方式二：clone 后本地跑

```bash
git clone git@github.com:Mark4551124015/zsh_setup.git
cd zsh_setup
./install.sh
```

安装完成后：

```bash
exec zsh          # 或重新打开终端
p10k configure     # 首次会自动弹出，也可随时手动重新配置
```

> 建议安装一款 **Nerd Font**（如 MesloLGS NF）并在终端设置里选用，否则 p10k 的图标会显示为方块/问号。
> 参考：https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k

## 自定义命令的代理地址

`functions.zsh` 里写死了 `127.0.0.1:7899`（Clash 系代理默认端口）。如果你的代理端口不同，
安装后直接编辑：

```bash
$EDITOR "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/functions.zsh"
```

## 以后再加新命令

不用改 `.zshrc`，直接在 `$ZSH_CUSTOM/` 下新建/编辑任意 `*.zsh` 文件，oh-my-zsh 启动时会自动加载。
