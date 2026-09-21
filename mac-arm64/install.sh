#!/bin/bash
# install.sh — 把 mac-arm64/ 装到宿主。幂等：第二次跑不应产生任何改动。
#
# 软链 vs 拷贝的判定依据是"谁会写这个文件"：
#   · 人编辑、程序只读        → 软链（改仓即生效）
#   · 程序会原子重写          → 拷贝（VS Code 改设置是 write-temp + rename，
#                                会把软链替换成普通文件，改动从此脱离版本控制且无声）
#   · 内含绝对路径            → 模板渲染（LaunchAgent plist）

set -uo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS=$(date +%Y%m%d-%H%M%S)
# 备份统一落到仓外的一个目录，不留在原地——iTerm2 的 DynamicProfiles/ 会解析目录下
# 所有文件，就地留一份 .bak 会变成 GUID 重复的第二个 profile。
BAK="$HOME/.dotfiles-backups/$TS"
n_link=0; n_copy=0; n_skip=0

# 建软链；目标已是同一条软链则跳过，是真实文件则先备份
_link() {                              # $1=仓内相对路径 $2=目标绝对路径
  local src="$SRC/$1" dst="$2"
  [ -e "$src" ] || { echo "  ✗ 缺源文件 $1"; return 1; }
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    n_skip=$((n_skip+1)); return 0
  fi
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mkdir -p "$BAK"; cp -p "$dst" "$BAK/$(basename "$dst")"; echo "  备份 → $BAK/$(basename "$dst")"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst" && { echo "  → $dst"; n_link=$((n_link+1)); }
}

# 内容相同则不动，避免每次跑都刷新 mtime
_copy() {
  local src="$SRC/$1" dst="$2"
  [ -e "$src" ] || { echo "  ✗ 缺源文件 $1"; return 1; }
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then n_skip=$((n_skip+1)); return 0; fi
  if [ -f "$dst" ]; then
    mkdir -p "$BAK"; cp -p "$dst" "$BAK/$(basename "$dst")"; echo "  备份 → $BAK/$(basename "$dst")"
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst" && { echo "  ⇒ $dst（拷贝）"; n_copy=$((n_copy+1)); }
}

echo "▸ zsh（软链）"
for f in .zshenv .zprofile .zshrc .zshrc.local; do _link "$f" "$HOME/$f"; done

echo "▸ 脚本与 profile（软链）"
_link bin/jserver-vm   "$HOME/.local/bin/jserver-vm"
_link iterm2/jserver.json \
      "$HOME/Library/Application Support/iTerm2/DynamicProfiles/jserver.json"

echo "▸ VS Code（拷贝——GUI 改设置会原子重写，软链会被替换掉）"
_copy vscode/settings.json          "$HOME/Library/Application Support/Code/User/settings.json"
_copy vscode/settings.insiders.json "$HOME/Library/Application Support/Code - Insiders/User/settings.json"

echo "▸ LaunchAgent（模板渲染——plist 里是绝对路径，换机即废）"
PLIST="$HOME/Library/LaunchAgents/com.juserch.jserver-vm.plist"
RENDERED=$(mktemp); sed "s|\$HOME|$HOME|g" "$SRC/launchd/com.juserch.jserver-vm.plist.template" > "$RENDERED"
if [ -f "$PLIST" ] && cmp -s "$RENDERED" "$PLIST"; then
  n_skip=$((n_skip+1))
else
  [ -f "$PLIST" ] && { mkdir -p "$BAK"; cp -p "$PLIST" "$BAK/$(basename "$PLIST")"; }
  mkdir -p "$(dirname "$PLIST")"; cp "$RENDERED" "$PLIST"; echo "  ⇒ $PLIST"; n_copy=$((n_copy+1))
fi
rm -f "$RENDERED"
plutil -lint "$PLIST" >/dev/null && echo "  plist 合法"
launchctl print "gui/$(id -u)/com.juserch.jserver-vm" >/dev/null 2>&1 \
  || { launchctl bootstrap "gui/$(id -u)" "$PLIST" 2>/dev/null && echo "  已注册开机自启"; }

echo "▸ 系统设置"
"$SRC/macos-defaults.sh" | sed 's/^/  /'

echo
echo "▸ 校验"
zsh -n "$HOME/.zshrc" && echo "  .zshrc 语法 OK"
bash -n "$HOME/.local/bin/jserver-vm" && echo "  jserver-vm 语法 OK"
python3 -c "import json;json.load(open('$HOME/Library/Application Support/iTerm2/DynamicProfiles/jserver.json'));print('  iTerm2 profile JSON OK')"
echo
echo "完成：软链 $n_link · 拷贝 $n_copy · 无变化 $n_skip"
