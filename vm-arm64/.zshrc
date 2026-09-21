# vm-arm64 — Ubuntu 26.04 ARM64 on UTM (jserver)
# 基于 nix/.zshrc 裁剪。差异见文件末尾 CHANGES。

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh
source $HOME/.antigen/antigen.zsh
antigen use oh-my-zsh
antigen theme romkatv/powerlevel10k
antigen bundle zsh-users/zsh-completions
antigen bundle git
antigen bundle extract
antigen bundle copypath
antigen bundle supercrabtree/k
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-history-substring-search
# conflict with fzf, vi-mode
# antigen bundle marlonrichert/zsh-autocomplete@main
antigen bundle djui/alias-tips
antigen bundle zsh-users/zsh-syntax-highlighting
# ZVM_INIT_MODE=sourcing   # vm-arm64: 改用默认 last-zle，见 CHANGES
antigen bundle jeffreytse/zsh-vi-mode
antigen apply

setopt interactivecomments

eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# My config
[ -f ~/.chrc ] && source ~/.chrc

# OpenClaw Completion（未装时跳过，避免启动报错）
[ -f "$HOME/.openclaw/completions/openclaw.zsh" ] && \
  source "$HOME/.openclaw/completions/openclaw.zsh"

# =====================================================================
# CHANGES vs nix/.zshrc (2026-09-20)
#
#   ZVM_INIT_MODE  注释掉 sourcing，改用 zvm 默认的 last-zle。
#                  原因：sourcing 模式下 zvm 在 antigen apply 时就初始化完毕并
#                  消费掉 zvm_after_init_commands，而 .chrc 在其后才 source、
#                  才往该数组注册回调——永远赶不上，fzf 键位绑定不会生效。
#                  last-zle 模式下 zvm 延到首个提示符才初始化，注册时机才正确。
#                  ✅ 实测（真 TTY）：bindkey | grep -c fzf = 4。
#                  ⚠️ 用 zsh -ic 测会得 0——那不渲染提示符，last-zle 不触发，
#                     是测试方法的假阴性，不是配置问题。
#
#   zsh-vi-mode    bundle 保留（与 nix/.zshrc 一致）。配套 vm-arm64/.chrc 的 fzf 初始化
#                  同样保持 zvm_after_init_commands 回调形式——两者必须成对：
#                    · 装 zvm + .chrc 直接绑定 → zvm 初始化时覆盖 fzf 键位
#                    · 不装 zvm + .chrc 用回调 → 回调永不执行，fzf 键位全失效
#                  改动任一侧时必须同时改另一侧。
#
#   openclaw 补全  硬编码路径 /home/juserch/... → $HOME，并加存在性守卫。
#                  openclaw 尚未安装，无守卫会在每次启动报 no such file。
# =====================================================================
