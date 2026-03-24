# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH=$HOME/.local/bin:$PATH

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
ZVM_INIT_MODE=sourcing
antigen bundle jeffreytse/zsh-vi-mode
antigen apply

setopt interactivecomments

eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# My config
[ -f ~/.chrc ] && source ~/.chrc
