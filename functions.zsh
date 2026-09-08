# ~/.oh-my-zsh/custom/functions.zsh
# 代理开关函数。由 oh-my-zsh 自动 source（无需在 .zshrc 里手动 source）。
#
# 用法：
#   vpn        开启代理（socks5h + http，用于科学上网）
#   quiteVPN   静默开启代理（同 vpn，但不打印提示，适合脚本里调用）
#   unvpn      关闭代理

vpn() {
  unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy

  export ALL_PROXY="socks5h://127.0.0.1:7899"
  export all_proxy="socks5h://127.0.0.1:7899"
  export http_proxy="http://127.0.0.1:7899"
  export https_proxy="http://127.0.0.1:7899"
  export NO_PROXY="localhost,127.0.0.1,::1"
  export no_proxy="localhost,127.0.0.1,::1"

  echo "Proxy enabled"
}

quiteVPN() {
  unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy

  export ALL_PROXY="http://127.0.0.1:7899"
  export all_proxy="http://127.0.0.1:7899"
  export http_proxy="http://127.0.0.1:7899"
  export https_proxy="http://127.0.0.1:7899"
  export NO_PROXY="localhost,127.0.0.1,::1"
  export no_proxy="localhost,127.0.0.1,::1"
}

unvpn() {
  unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy
  echo "Proxy disabled"
}
