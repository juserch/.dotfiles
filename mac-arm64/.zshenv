# ~/.zshenv — 所有 zsh 调用都会读，只放必须早于 /etc/zshrc 生效的东西。

# /etc/zshrc_Apple_Terminal 会把 HISTFILE 劫持成 ~/.zsh_sessions/<UUID>.historynew，
# 造成每个终端窗口一份互不可见的历史。它在 /etc/zshrc 里被 source，早于 ~/.zshrc，
# 所以这个开关只能放在这里。
export SHELL_SESSIONS_DISABLE=1

# ── locale 规范化 ──────────────────────────────────────────────────────────
# macOS Terminal 在"系统语言+地区"组合没有对应 locale 时（中文系统常见），
# 会只导出一个 LC_CTYPE=UTF-8。这不是合法的 locale 名：macOS 的 libc 容忍它，
# 但 glibc 不认，而 /etc/ssh/ssh_config.d/100-macos.conf 的 `SendEnv LANG LC_*`
# 会把它原样送到远端，于是 Linux 上的 man/manpath/perl 报
#   "can't set the locale; make sure $LC_* and $LANG are correct"
# 在源头补成合法值，本地与所有 ssh 目标一并解决。
export LANG=${LANG:-en_US.UTF-8}
[[ $LC_CTYPE == "UTF-8" ]] && export LC_CTYPE=$LANG

# ── Homebrew ───────────────────────────────────────────────────────────────
# 官方源的 bottle 走 ghcr.io，本网络下实测**卡死在 45 KB 不再增长**，且不报错、
# 不超时，看上去只是"装得慢"。API（brew info）能通，卡的是 blob 下载。
# 换 USTC 镜像：实测 0.77s 可达（tuna 8s，nju/ustc 均无 nerd-fonts 镜像）。
# ⚠️ 只影响 formula 的 bottle；cask 仍从上游（GitHub / 厂商站）下，不吃这个变量。
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
