TEXT_FG_BLACK=$'\033[30m'
TEXT_FG_RED=$'\033[31m'
TEXT_FG_GREEN=$'\033[32m'
TEXT_FG_YELLOW=$'\033[33m'
TEXT_FG_BLUE=$'\033[34m'
TEXT_FG_MAGENTA=$'\033[35m'
TEXT_FG_CYAN=$'\033[36m'
TEXT_FG_WHITE=$'\033[37m'
TEXT_BOLD=$'\033[1m'
TEXT_UNDERLINE=$'\033[4m'
TEXT_REVERSE=$'\033[3m'
TEXT_RESET=$'\033[0m'

if command -v tput &>/dev/null; then
  TEXT_FG_BLACK=$(tput setaf 0)
  TEXT_FG_RED=$(tput setaf 1)
  TEXT_FG_GREEN=$(tput setaf 2)
  TEXT_FG_YELLOW=$(tput setaf 3)
  TEXT_FG_BLUE=$(tput setaf 4)
  TEXT_FG_MAGENTA=$(tput setaf 5)
  TEXT_FG_CYAN=$(tput setaf 6)
  TEXT_FG_WHITE=$(tput setaf 7)
  TEXT_BOLD=$(tput bold)
  TEXT_UNDERLINE=$(tput smul)
  TEXT_REVERSE=$(tput rev)
  TEXT_RESET=$(tput sgr0)
fi

get_effect_code() {
  case "$1" in
    black)
      printf "$TEXT_FG_BLACK"
      ;;
    red)
      printf "$TEXT_FG_RED"
      ;;
    green)
      printf "$TEXT_FG_GREEN"
      ;;
    yellow)
      printf "$TEXT_FG_YELLOW"
      ;;
    blue)
      printf "$TEXT_FG_BLUE"
      ;;
    magenta)
      printf "$TEXT_FG_MAGENTA"
      ;;
    cyan)
      printf "$TEXT_FG_CYAN"
      ;;
    white)
      printf "$TEXT_FG_WHITE"
      ;;
    bold)
      printf "$TEXT_BOLD"
      ;;
    ul)
      printf "$TEXT_UNDERLINE"
      ;;
    rev)
      printf "$TEXT_REVERSE"
      ;;
    *)
      echo "Unknown text effect code: $1" >&2
      exit 1
      ;;
  esac
}

style() {
  styles="$1"
  [[ "$styles" == "path" ]] && styles="bold,blue"

  IFS=',' read -ra styles <<< "$styles"

  for style in "${styles[@]}"; do
    get_effect_code "$style"
  done

  printf '%s%s' "$2" "$TEXT_RESET"
}

info() {
  if [[ "$1" == "i" ]]; then
    shift
    echo "  $@"
  else
    echo "$(style 'cyan' '▶') $@"
  fi
}

error() {
  echo "$(style 'red' '!!') $@"
}

usage() {
  printf "Usage: $0\
 $(style 'cyan' '<function>')\
 [$(style 'yellow' '-optionA')]\
 [$(style 'magenta' '-optionB ')\
 $(style 'path' '~/file')]\n"
}

missing_config() {
  echo "Missing config. Generate sample:"
  echo "$(style 'bold,cyan' "$0")"\
    "$(style 'green' 'sample-config') >"\
    "$(style 'path' '~/.config/nos/config')"
}

sample_config() {
  cat <<EOF
STOW_TARGET=~/

# Simulated run without changes. Only shows what symlinks stow would create.
#STOW_DRY_RUN=1

# Whether to run stow during service updates.
AUTO_UPDATE_STOW=1

# Public dotfiles repo.
PUBLIC_PATH=~/configs/dotfiles
PUBLIC_REPO=git@github.com:SampleUser/dotfiles.git

# Optional repo with stuff you don't want out in public.
# Even though it's private, DON'T put any ssh keys or plain text passwords in there.
PRIVATE_PATH=~/configs/dotfiles-private
PRIVATE_REPO=git@github.com:SampleUser/dotfiles-private.git

# Optional NixOS config files repo.
NIXOS_PATH=~/configs/nixos
NIXOS_REPO=git@github.com:SampleUser/nixos-conf.git

# ~/.ssh/ key to be used for git. If you don't want to or can't use your regular key.
#REPO_SSH_KEY=id_ed25519
EOF
}
