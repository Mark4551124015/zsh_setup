# ~/.oh-my-zsh/custom/functions.zsh
# Proxy helpers, automatically sourced by oh-my-zsh.
# No manual source command is needed in .zshrc.
#
# Usage:
#   vpn        Enable SOCKS5h and HTTP proxy environment variables.
#   quiteVPN   Enable HTTP proxy environment variables silently for scripts.
#   unvpn      Disable proxy environment variables.

vpn() {
  unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy

  export ALL_PROXY="socks5h://127.0.0.1:7897"
  export all_proxy="socks5h://127.0.0.1:7897"
  export http_proxy="http://127.0.0.1:7897"
  export https_proxy="http://127.0.0.1:7897"
  export NO_PROXY="localhost,127.0.0.1,::1"
  export no_proxy="localhost,127.0.0.1,::1"

  echo "Proxy enabled"
}

quiteVPN() {
  unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy

  export ALL_PROXY="http://127.0.0.1:7897"
  export all_proxy="http://127.0.0.1:7897"
  export http_proxy="http://127.0.0.1:7897"
  export https_proxy="http://127.0.0.1:7897"
  export NO_PROXY="localhost,127.0.0.1,::1"
  export no_proxy="localhost,127.0.0.1,::1"
}

unvpn() {
  unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy
  echo "Proxy disabled"
}
