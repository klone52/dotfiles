# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d $ZINIT_HOME ]; then 
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# append completions to fpath
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
# initialise completions with ZSH's compinit

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey '^f' autosuggest-accept

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
# zstyle ':completion:*' menu select
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias n='nvim'
alias c='clear'
alias lzg='lazygit'
alias lzd='lazydocker'
alias lzn='lazynpm'

# Custom commands
# function fcv() {
#   fury create-version "$(fury list-versions -a |  grep master | head -1 | awk '{print $1}')-$1"
# }

function fcv {
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  NC='\033[0m' # No Color 

  # Check for option flags
  if [[ $1 == "-n" ]]; then
    echo "Don't runing test/linter"
  else
    #check if is js/ts project
    fe_elements_found="$(ls | grep -ice '^package')"
    be_elements_found="$(ls | grep -ice '^go.mod')"

    # Run frontend test
    if [[ $fe_elements_found -gt 0 ]]; then
      error=false
      echo "\nNode enviroment detected..."
      echo "Runing Jest Test..."
      if ! npm run test; then
        echo -e "\n${RED}Tests failed !!${NC}"
        error=true
      fi
      if [[ $(npm run lint | grep -ce 'error') -gt 0 ]]; then
        echo -e "\n${RED}Linter error !!${NC}"
        error=true
      fi

      if error; then
        return
      fi
    fi

    # Run backend test
    if [[ $be_elements_found -gt 0 ]]; then
      echo "\nGo enviroment detected..."
      echo "Runing Test..."
      failing_test=$(go test --cover ./... --json | grep -ce 'FAIL' )
      if [[ $failing_test -gt 0 ]]; then
        echo -e "\n${RED}Tests failed !!${NC}"
        return
      fi
    fi
  fi

  # Obtiene el nombre de la branch
  branch_name="$(git branch --show-current)"

  # Revisa si es una branch valida, ej: feature/cxactions-100/test-branch-1
  echo "\nValidating branch name..."
  echo $branch_name

  if ! [[ $branch_name =~ ^(feature|release|hotfix)/(cxactions|CXACTIONS)-[0-9]*/([a-zA-Z0-9_-]*) ]]; then
    echo -e "\n${RED}Not a valid branch 🚫${NC}"
    echo 'Plase use de format: <type_of_branch>/<jira_ticket>/<small_description>'
    echo 'example: feature/cxactions-000/example-feat-0'
    return
  fi

  # Revisar si rama está al día con develop
  echo "\nValidating if branch is up to date with develop..."
  behind=$(git rev-list --left-right --count origin/develop...$branch_name | awk '{print $1}')
  if [[ "$behind" -gt "0" ]]; then
    echo "Branch behind develop by ${behind} commits 👀"
    echo "${YELLOW}Update your branch !!${NC}"
    return
  fi
  echo -e "${GREEN}Branch up to date${NC}"

  # Guardar nombre especifico de rama ej: test-branch-1
  # compatible con bash o zsh
  name=$BASH_REMATCH[3]
  (($name)) || name=$match[3]

  # Revisar si ya existe versión para esta rama
  echo "\nValidating if branch already has versions..."
  last_match="$(fury list-versions -a |  grep $branch_name | sort -rV | head -1)"

  if [[ -n $last_match ]]; then
    echo "Version found!"
    # Obtener version y status de pipeline
    last_version="$(echo $last_match | awk '{print $1}')"
    last_status="$(echo $last_match | awk '{print $2}')"

    # 0. Revisar si ultimo commit corresponde a ultima versión -- Idempotencia
    tag_commit="$( git log -1 $last_version --pretty='format:%H' )"
    current_commit="$(git log -n 1 --pretty=format:"%H")"

    if [[ $tag_commit == $current_commit ]]; then
      echo -e "No changes, already commit correspond to version: ${RED}$last_version ${NC}!!!"
      return
    fi

    # 1. Si status es error uso misma versión
    if [[ "$last_status" == "error" ]]; then
      echo "Last version status is error: recycling version 🤔"
      fury create-version "$last_version"
      return
    fi

    # 2. Revisar si el status es finished o creating  => creo nueva versión con increment
    echo "\nCreating version..."
    arr=(${(s/-/)last_version})
    tmp=$((arr[-1]+1))
    arr[-1]=$tmp

    new_version=$(IFS=- ; echo "${arr[*]}")
    fury create-version "$new_version"
    return
  fi

  # Si no existe version previa
  # Obtener ultima versión de master y crear version a partir de ahi
  echo "\nNot found previous version, creating new version from master version..."
  current_master="$(fury list-versions -a |  grep master | head -1 | awk '{print $1}')"

  major="$(echo $current_master | awk -F. '{print $1}')"
  minor="$(echo $current_master | awk -F. '{print $2}')"
  old_patch="$(echo $current_master | awk -F. '{print $3}')"
  new_patch=$(($old_patch+1))

  fury create-version "$major.$minor.$new_patch-$name-0"
  echo -e "${GREEN}Done !${NC}"
  return
}

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Custom cli

# Slack Cli
export PATH="/Users/nhernandezpe/.slack/bin:$PATH"

# Auto Select Node Version
function nvmSetVersion(){
    if [ -f .nvmrc ]; then
        nvm install
    fi
}

chdir() {
  local action="$1"; shift
  case "$action" in
    # popd needs special care not to pass empty string instead of no args
    popd) [[ $# -eq 0 ]] && builtin popd || builtin popd "$*" ;;
    cd)
      if [ $# -eq 0 ]
      then
        builtin $action  "$HOME" ;
      else
        builtin $action "$*";
      fi;;
    pushd) builtin $action "$*" ;;
    *) return ;;
  esac
  # now do stuff in the new pwd

  nvmSetVersion
}

# nordic-doctor
export NORDIC_DOCTOR_DIR="$HOME/.nordic-doctor"
export PATH="$NORDIC_DOCTOR_DIR/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ASDF
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
export RANGER_FURY_LOCATION=/Users/nhernandezpe/.fury #Added by Fury CLI
export RANGER_FURY_VENV_LOCATION=/Users/nhernandezpe/.fury/fury_venv #Added by Fury CLI

# Added by Fury CLI installation process
declare FURY_BIN_LOCATION="/Users/nhernandezpe/.fury/fury_venv/bin" # Added by Fury CLI installation process
export PATH="$PATH:$FURY_BIN_LOCATION" # Added by Fury CLI installation process
# Added by Fury CLI installation process
