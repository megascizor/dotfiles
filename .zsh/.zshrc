#!/usr/bin/env zsh
# Parameters
HISTFILE="${ZDOTDIR}/.zsh_history"
HISTSIZE=10000
SAVEHIST=1000000
if [[ "${UID}" == 0 ]]; then
  unset HISTFILE
  SAVEHIST=0
fi

WORDCHARS="*?_-.[]~=&;!#$%^(){}<>"

# Options
setopt \
  always_last_prompt \
  always_to_end \
  auto_list \
  auto_menu \
  auto_param_keys \
  auto_param_slash \
  auto_remove_slash \
  complete_in_word \
  list_types \
  brace_ccl \
  equals \
  extended_glob \
  glob_dots \
  magic_equal_subst \
  mark_dirs \
  append_history \
  bang_hist \
  extended_history \
  hist_expire_dups_first \
  hist_ignore_all_dups \
  hist_ignore_dups \
  hist_ignore_space \
  hist_no_functions \
  hist_no_store \
  hist_reduce_blanks \
  hist_save_no_dups \
  hist_verify \
  inc_append_history \
  share_history \
  correct \
  correct_all \
  ignore_eof \
  interactive_comments \
  path_dirs \
  print_eight_bit \
  rm_star_wait \
  auto_resume \
  long_list_jobs \
  notify \
  multios

unsetopt \
  list_beep \
  case_glob \
  hist_beep \
  clobber \
  flow_control \
  beep

# Key bindings
bindkey -v

bindkey -M viins \
  '^F' forward-char \
  '^B' backward-char \
  '^A' beginning-of-line \
  '^E' end-of-line \
  '^K' kill-line \
  '^Y' yank \
  '^W' backward-kill-word \
  '^U' backward-kill-line \
  '^H' backward-delete-char \
  '^?' backward-delete-char \
  '^G' send-break \
  '^P' up-line-or-history \
  '^N' down-line-or-history \
  '^D' delete-char-or-list
bindkey -M vicmd \
  '^A' beginning-of-line \
  '^E' end-of-line \
  '^K' kill-line \
  '^P' up-line-or-history \
  '^N' down-line-or-history \
  '^Y' yank \
  '^W' backward-kill-word \
  '^U' backward-kill-line

autoload -Uz is-at-least
if is-at-least 5.0.8; then
  autoload -Uz surround
  zle -N delete-surround surround
  zle -N change-surround surround
  zle -N add-surround surround
  bindkey -a \
    cs change-surround \
    ds delete-surround \
    ys add-surround
  bindkey -M visual S add-surround
fi

# Completions
zstyle ':completion:*' \
  auto-description '%d' \
  completer _complete _match _approximate \
  format '%F{yellow}-- %d --%f' \
  group-name '' \
  matcher-list 'm:{a-z}={A-Z}' \
  use-cache true \
  verbose yes

zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'

zstyle ':completion:*:*files' ignored-patterns '*?.o' '*?~' '*\#'
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:cd:*' ignored-parents parent pwd

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Utilities
autoload -Uz zcalc

# External tools
export FZF_DEFAULT_OPTS='
  --extended
  --ansi
  --multi
  --border
  --reverse
'

eval "$(sheldon source)"
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
[[ -f "${HOME}/google-cloud-sdk/path.zsh.inc" ]] && source $HOME/google-cloud-sdk/path.zsh.inc
[[ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]] && source $HOME/google-cloud-sdk/completion.zsh.inc
[[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Aliases
function ghq-cd() {
  local repository="$(ghq list | fzf +m)"
  [[ -n "${repository}" ]] && cd "$(ghq root)/${repository}"
}

alias \
  gl='ghq-cd' \
  vi='nvim' \
  vim='nvim' \
  ls='eza' \
  ll='eza --classify --git --long' \
  la='eza --all --classify' \
  lla='eza -all --classify --git --long --git' \
  tree='eza --git-ignore --tree' \
  cat='bat --theme Dracula' \
  less='bat --theme Dracula' \
  grep='rg --color=auto' \
  diff="delta" \
  du='dust -r' \
  find='fd' \
  mv='mv -i' \
  rm='rm -i' \
  cp="${ZSH_VERSION:+nocorrect} cp -i" \
  mkdir="${ZSH_VERSION:+nocorrect} mkdir" \
  sudo="${ZSH_VERSION:+nocorrect} sudo"

if [ $(uname) = 'Linux' ]; then
  alias \
    pbcopy='xclip -selection c' \
    pbpaste='xclip -selection c -o'
fi
if [[ $(uname -r) =~ 'microsoft' ]]; then
  alias \
    pbcopy='clip.exe' \
    pbpaste='powershell.exe -Command Get-Clipboard'
fi

# Global aliases
alias -g \
  G='| rg' \
  L='| less' \
  X='| xargs' \
  N='| > /dev/null 2 > &1' \
  N1='| > /dev/null' \
  N2='| 2 > /dev/null' \
  H='| head' \
  T='| tail' \
  CP='| pbcopy' \
  CC='tee /dev/tty | pbcopy'

# NOTE: Take a profile if 'zprof' is loaded
if which zprof > /dev/null; then
  zprof | less
fi
