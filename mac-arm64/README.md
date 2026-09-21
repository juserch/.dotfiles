# mac-arm64 — MacBook Pro M5 / macOS 26 宿主

与 `nix/`（旧 WSL）、`vm-arm64/`（jserver VM）同级的平台目录。
**这台机器是宿主，不是开发环境**：代码与工具链在 VM 里（方案 §3.5），
宿主只跑编辑器、Ollama、UTM，以及连过去的终端。

调查与决策全文见工作区 `ienv/shell/host-shell-assessment.md`。

## 安装

```bash
git clone git@github.com:juserch/.dotfiles.git ~/.dotfiles
~/.dotfiles/mac-arm64/install.sh          # 幂等，第二次跑应显示"无变化"
```

## 内容

| 路径 | 装到 | 方式 |
|---|---|---|
| `.zshenv` `.zprofile` `.zshrc` `.zshrc.local` | `~/` | 软链 |
| `bin/jserver-vm` | `~/.local/bin/` | 软链 |
| `iterm2/jserver.json` | `~/Library/Application Support/iTerm2/DynamicProfiles/` | 软链 |
| `vscode/settings*.json` | Code / Code - Insiders 的 `User/` | **拷贝** |
| `launchd/*.plist.template` | `~/Library/LaunchAgents/` | **模板渲染** |
| `macos-defaults.sh` | — | 执行 |

**为什么 VS Code 是拷贝不是软链**：GUI 里改设置是 write-temp + rename，
会把软链替换成普通文件，之后的改动脱离版本控制且毫无提示。
改完设置要回仓：`cp ~/Library/.../User/settings.json vscode/settings.json`。

## 与 `nix/` 的关键差异

| 项 | 原因 |
|---|---|
| **不用 oh-my-zsh / antigen / p10k** | 宿主是纯 zsh 5.9 手写配置，零外部依赖，冷启 0.36 s。别名族与 fzf/zoxide 以增量方式补在 `.zshrc.local`，见 assessment §4 |
| `ls -G` 而非 `ls --color=auto` | BSD ls |
| `fs` 用 `lsof -iTCP` 而非 `ss` | macOS 无 `ss` |
| **不设 `OLLAMA_HOST`** | 同名变量在宿主是**服务端绑定地址**（VM 里才是客户端目标）。照抄 VM 的 `192.168.64.1` 会把 ollama 绑到 vmnet 接口 |
| 提示符 `mac ▸`（琥珀） | 与 guest 的 p10k `❯` 区分，防止在错机器上敲命令 |
| `HOMEBREW_BOTTLE_DOMAIN` 指向 USTC | 官方 ghcr.io 的 bottle 下载在本网络下卡死在 45 KB 不动 |

## 已知坑（都实测过）

* **`open -j` 会让 UTM 4.7.5 段错误**——隐藏启动时崩在 SwiftUI 主窗口构建。
  拉 VM 一律让 `utmctl` 自己拉起 UTM，不要预先 `open`。
* **`utmctl` 把错误打在 stdout 且退出码恒为 0**——判成败只能回查 `status`。
* **宿主睡眠会挂起 VM**（本机 `pmset sleep 1`）。`jserver-vm` 用
  `caffeinate -i -s -w <UTM pid>` 持断言；只用 `-s` 挡不住闲置睡眠。
* **`$var` 后紧跟全角标点**会被 bash 吃进变量名，中文输出里一律写 `${var}`。
