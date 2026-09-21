# ~/.zshrc — 交互式 zsh 配置。纯 zsh 5.9 内置能力，无任何外部依赖。
# 仅在交互式 shell 中生效；脚本走 .zshenv。
[[ -o interactive ]] || return

# ══ 历史 ═══════════════════════════════════════════════════════════════════
# 兜底：即使 .zshenv 的 SHELL_SESSIONS_DISABLE 被绕过，也把 HISTFILE 钉回来。
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000          # 内存中保留的条数
SAVEHIST=100000          # 落盘的条数（原来是 1000）

setopt share_history          # 多个窗口实时共享历史
setopt inc_append_history     # 执行即写盘，不必等 shell 退出
setopt extended_history       # 记录时间戳和耗时
setopt hist_ignore_all_dups   # 重复命令只保留最新那条
setopt hist_ignore_space      # 以空格开头的命令不入历史（敲密码时有用）
setopt hist_reduce_blanks
setopt hist_verify            # !! / !$ 展开后先回显，再按回车才执行
setopt hist_no_store          # history 命令自身不入历史

# ══ 目录 ═══════════════════════════════════════════════════════════════════
setopt auto_cd                # 直接敲路径即 cd
setopt auto_pushd             # 每次 cd 自动入栈，配合 `cd -<Tab>` 跳回
setopt pushd_ignore_dups pushd_silent
DIRSTACKSIZE=20

# ══ 杂项 ═══════════════════════════════════════════════════════════════════
setopt interactive_comments   # 命令行里 # 后面算注释
setopt no_beep
setopt no_flow_control        # 把 ^S / ^Q 还给编辑器
setopt long_list_jobs
unsetopt correct correct_all  # 不要自作主张"纠正"命令拼写

export CLICOLOR=1
export LSCOLORS=ExGxFxdaCxDaDahbadacec
export LESS='-R -F -X'
export EDITOR=${EDITOR:-vim}

# ══ 补全 ═══════════════════════════════════════════════════════════════════
# brew 装的包会把补全函数丢在这里（git、brew 自身等）
[[ -d /opt/homebrew/share/zsh/site-functions ]] && \
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

autoload -Uz compinit
# 完整的 fpath 安全检查每天只做一次，其余时间直接读缓存，省掉启动开销
_zcompdump=$HOME/.zcompdump
if [[ -n $_zcompdump(#qN.mh+24) ]] || [[ ! -f $_zcompdump ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi
unset _zcompdump

setopt complete_in_word       # 光标停在词中间也能补
setopt always_to_end
setopt no_list_beep

zstyle ':completion:*' menu select                       # 方向键在候选里选
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
zstyle ':completion:*:warnings'     format '%F{red}无匹配%f'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/compcache"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'
zstyle ':completion:*:cd:*' ignore-parents parent pwd    # cd ../<Tab> 不提示当前目录

# ══ 键位 ═══════════════════════════════════════════════════════════════════
bindkey -e                    # emacs 键位

# ↑↓ 按已输入的前缀过滤历史，而不是无脑翻整条历史
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
for _k in "$terminfo[kcuu1]" '^[[A' '^[OA'; do
  [[ -n $_k ]] && bindkey -- "$_k" up-line-or-beginning-search
done
for _k in "$terminfo[kcud1]" '^[[B' '^[OB'; do
  [[ -n $_k ]] && bindkey -- "$_k" down-line-or-beginning-search
done
unset _k

bindkey '^[[1;5C' forward-word          # ctrl-→
bindkey '^[[1;5D' backward-word         # ctrl-←
bindkey '^[[1;3C' forward-word          # opt-→
bindkey '^[[1;3D' backward-word         # opt-←
bindkey '^[[3~'   delete-char
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line
bindkey '^U'      backward-kill-line    # bash 风格：只删光标左边，不是整行

# ══ 提示符 ═════════════════════════════════════════════════════════════════
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr ' ✗'
zstyle ':vcs_info:git:*' stagedstr   ' ●'
zstyle ':vcs_info:git:*' formats       ' %F{242}on%f %F{178}%b%f%F{yellow}%u%c%f'
zstyle ':vcs_info:git:*' actionformats ' %F{242}on%f %F{178}%b%f %F{red}(%a)%f'

_precmd_vcs_info() { vcs_info }
precmd_functions+=(_precmd_vcs_info)

setopt prompt_subst
# 琥珀 mac 标签 = 主机身份；沙褐路径；▸ 绿/红 = 上条命令成功/失败（guest 用 ❯，勿混）
PROMPT='%F{214}%Bmac%b%f %F{180}%~%f${vcs_info_msg_0_} %(?.%F{green}.%F{red})▸%f '

# ══ 别名 ═══════════════════════════════════════════════════════════════════
alias ls='ls -G'
alias ll='ls -lhG'
alias la='ls -lhAG'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias df='df -h'
alias du='du -h'

# UTM 的 utmctl 不在 PATH 里
[[ -x /Applications/UTM.app/Contents/MacOS/utmctl ]] && \
  alias utmctl='/Applications/UTM.app/Contents/MacOS/utmctl'

# ══ ssh 远程时切换窗口背景色 ═══════════════════════════════════════════════
# 在同一个窗口里 ssh 出去时，Terminal 的 profile 不会变，提示符又只占一小块。
# 这里在连接期间改整窗背景色，给出"我在远程"的全屏信号，退出自动还原。
# 只在 Apple Terminal 下启用；VSCode 等其他终端里 ssh 原样透传。
# 判定这次调用是不是「交互式登录到单台主机」。是则打印主机名、返回 0；
# 带了远程命令或非 tty 则返回 1——那类一次性调用不该改变窗口外观。
_ssh_lone_host() {
  local -a need_arg=(-b -c -D -E -e -F -I -i -J -L -l -m -O -o -p -Q -R -S -W -w)
  local -a positional=()
  local i=1 a
  while (( i <= $# )); do
    a=${@[i]}
    if [[ $a == -* ]]; then
      (( ${need_arg[(I)$a]} )) && (( i += 2 )) || (( i++ ))
    else
      positional+=($a); (( i++ ))
    fi
  done
  [[ -t 1 ]] && (( ${#positional} == 1 )) || return 1
  print -r -- ${positional[1]}
}

if [[ $TERM_PROGRAM == "Apple_Terminal" ]]; then

  # 远程时的背景色，16 位 RGB（0-65535）。纯黑 #1F1F1F，与 VSCode
  # Dark Modern 的编辑区背景一致。
  typeset -g _SSH_BG_REMOTE='7967, 7967, 7967'

  # 按 tty 精确定位标签页——避免你切到别的窗口时改错对象。
  # $2 留空 = 读取当前颜色；给值 = 设置颜色。
  _term_bg() {
    local tty=$1 color=$2 body
    if [[ -z $color ]]; then
      body="return background color of t"
    else
      body="set background color of t to {$color}
            return \"\""
    fi
    osascript 2>/dev/null <<OSA
tell application "Terminal"
  repeat with w in windows
    repeat with t in tabs of w
      if tty of t is "$tty" then
        $body
      end if
    end repeat
  end repeat
end tell
OSA
  }

  ssh() {
    # 只有交互式登录才切色。`ssh host <命令>` 这种一次性调用直接透传，
    # 否则每次都会闪一下背景。判定逻辑见上面的 _ssh_lone_host。
    _ssh_lone_host "$@" >/dev/null || { command ssh "$@"; return }

    local orig=$(_term_bg $TTY)
    if [[ -z $orig ]]; then          # 拿不到颜色（无授权/非 Terminal）就别折腾
      command ssh "$@"
      return
    fi

    _term_bg $TTY "$_SSH_BG_REMOTE"
    {
      command ssh "$@"
    } always {
      _term_bg $TTY "$orig"          # 正常退出、Ctrl-C、连接中断都会走到
    }
  }

  # 兜底：万一 shell 被强杀导致颜色卡在远程色，手动敲这个复位
  bgreset() { _term_bg $TTY '6447, 7462, 10000'; }
elif [[ $TERM_PROGRAM == "iTerm.app" ]]; then

  # iTerm2 没有 Terminal.app 那套可被 AppleScript 逐标签寻址的窗口模型，
  # 改用它自己的 OSC 1337：SetBadgeFormat 在窗口右上角打一个半透明大字。
  # 比换背景色更显眼，且退出即清，不存在"颜色卡住"的残留问题。
  # ⚠️ tmux 里需要 passthrough 包装，此处不处理——宿主侧不跑 tmux。
  _iterm_badge() {
    printf '\033]1337;SetBadgeFormat=%s\a' "$(printf '%s' "$1" | base64 | tr -d '\n')"
  }

  ssh() {
    local host
    host=$(_ssh_lone_host "$@") || { command ssh "$@"; return }
    _iterm_badge "$host"
    {
      command ssh "$@"
    } always {
      _iterm_badge ''               # 正常退出、Ctrl-C、连接中断都会走到
    }
  }

  # 与 Apple Terminal 分支同名的兜底：清掉残留角标
  bgreset() { _iterm_badge ''; }

fi

# 本机私有配置，不纳入版本管理
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local

# ══ 交互增强（brew 装，无框架）══════════════════════════════════════════════
# 必须放在最后：syntax-highlighting 要求在所有定义 zle widget 的配置之后加载，
# 否则它包不住后面才注册的 widget（fzf 的绑定在 ~/.zshrc.local 里）。
_brew_share=${HOMEBREW_PREFIX:-/opt/homebrew}/share
# 灰字提示上一条匹配的历史命令，→ 或 ^E 接受
[[ -r $_brew_share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source $_brew_share/zsh-autosuggestions/zsh-autosuggestions.zsh
# 命令着色：绿=可执行，红=找不到
[[ -r $_brew_share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source $_brew_share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
unset _brew_share
