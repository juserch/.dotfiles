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

echo "▸ Terminal：默认 profile 的字号与窗口尺寸"
# 字号与行列数都挂在 profile 上，不在窗口上——手动拖窗口只影响当前那一个。
# 132x42 @ 14pt：3456x2234 Retina（逻辑 1728x1117）下约占 64%x67%，可与编辑器并排。
osascript -e 'tell application "Terminal"
  set font size         of settings set "Clear Dark" to 14
  set number of columns of settings set "Clear Dark" to 132
  set number of rows    of settings set "Clear Dark" to 42
end tell' 2>/dev/null || echo "  （Terminal 未运行或无自动化授权，跳过）"

echo "▸ iTerm2：默认 profile = jserver，本地 Default profile 也调成一致外观"
# 动态 profile（iterm2/jserver.json）只定义 profile 本身；"哪个是默认"与内置
# Default profile 的外观都存在 com.googlecode.iterm2.plist 里，得单独写。
# ⚠️ iTerm2 退出时会把内存里的偏好整体写回，运行中改必被覆盖——故先判进程。
if pgrep -x iTerm2 >/dev/null 2>&1; then
  echo "  ⚠️ iTerm2 正在运行，跳过（先退出再跑本脚本）"
else
  defaults write com.googlecode.iterm2 "Default Bookmark Guid" \
    -string "A4812E9A-FDF6-478C-B467-2CE94F93D6EE"     # jserver (VM)
  python3 - <<'PYEOF'
import plistlib, pathlib
p = pathlib.Path.home()/"Library/Preferences/com.googlecode.iterm2.plist"
if p.exists():
    d = plistlib.loads(p.read_bytes())
    def c(r,g,b): return {"Color Space":"sRGB","Red Component":r,"Green Component":g,
                          "Blue Component":b,"Alpha Component":1.0}
    for b in d.get("New Bookmarks", []):
        if b.get("Name") == "Default":                  # iTerm2 里开本地 shell 时用
            b["Normal Font"]="MesloLGSNF-Regular 14"
            b["Columns"]=132; b["Rows"]=42
            b["Background Color"]=c(0.098,0.114,0.153)  # #191D27，与宿主 Terminal 一致
            b["Foreground Color"]=c(0.878,0.878,0.878)
            b["Use Non-ASCII Font"]=False
            b["Set Local Environment Vars"]=0   # 见下方说明，防 locale 弹窗
    p.write_bytes(plistlib.dumps(d))
    print("    Default profile → MesloLGSNF-Regular 14 · 132x42 · 深色 · 不设 locale")
PYEOF
fi

cat <<'NOTE'

▸ 需手工处理的两项（脚本不碰）：
  1. VM 无窗口化：UTM 容器里的 Linux.utm/config.plist 要 Display=[] + Serial=[{Mode:Ptty}]
     不入库——含 VM UUID 与磁盘路径，属机器本地状态。改法见 assessment §7.5。
  2. 宿主自动睡眠是 pmset sleep 1，会把 VM 挂起。对策是 jserver-vm 里的
     caffeinate -i -s -w <UTM pid>（断言绑 UTM 生命周期），不改全局电源策略。
NOTE
