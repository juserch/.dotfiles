#!/bin/bash
# macos-defaults.sh — 那些"不是配置文件"的设置。
# 每一条都是 2026-09-21 排查中踩出来的，详见 ienv/shell/host-shell-assessment.md §7。
# 幂等，可重复执行。

set -uo pipefail

echo "▸ UTM：后台常驻（无窗口运行 guest）"
# 关掉所有窗口后 UTM 不退出——没有这条，关窗=退出 UTM=连带停 VM
defaults write com.utmapp.UTM KeepRunningAfterLastWindowClosed -bool true
defaults write com.utmapp.UTM ShowMenuIcon  -bool true    # 无窗口时唯一的可见入口
defaults write com.utmapp.UTM HideDockIcon  -bool true    # 下次启动生效
defaults write com.utmapp.UTM NSAppSleepDisabled     -bool true   # 防 App Nap 挂起 VM
defaults write com.utmapp.UTM NSQuitAlwaysKeepsWindows -bool false # 关掉窗口状态恢复

echo "▸ Terminal：默认 profile 字号（12 太小）"
# 字号挂在 profile 上，不在窗口上；手动调窗口只影响当前窗口
osascript -e 'tell application "Terminal" to set font size of settings set "Clear Dark" to 14' 2>/dev/null \
  || echo "  （Terminal 未运行或无自动化授权，跳过）"

cat <<'NOTE'

▸ 需手工处理的两项（脚本不碰）：
  1. VM 无窗口化：UTM 容器里的 Linux.utm/config.plist 要 Display=[] + Serial=[{Mode:Ptty}]
     不入库——含 VM UUID 与磁盘路径，属机器本地状态。改法见 assessment §7.5。
  2. 宿主自动睡眠是 pmset sleep 1，会把 VM 挂起。对策是 jserver-vm 里的
     caffeinate -i -s -w <UTM pid>（断言绑 UTM 生命周期），不改全局电源策略。
NOTE
