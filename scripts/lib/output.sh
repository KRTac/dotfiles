TEXT_FG_BLACK=$'\033[30m'
TEXT_FG_RED=$'\033[31m'
TEXT_FG_GREEN=$'\033[32m'
TEXT_FG_YELLOW=$'\033[33m'
TEXT_FG_BLUE=$'\033[34m'
TEXT_FG_MAGENTA=$'\033[35m'
TEXT_FG_CYAN=$'\033[36m'
TEXT_FG_WHITE=$'\033[37m'
TEXT_BOLD=$'\033[1m'
TEXT_DIM=$'\033[38m'
TEXT_REVERSE=$'\033[3m'
TEXT_UNDERLINE=$'\033[4m'
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
  TEXT_DIM=$(tput setaf 8)
  TEXT_REVERSE=$(tput rev)
  TEXT_UNDERLINE=$(tput smul)
  TEXT_RESET=$(tput sgr0)
fi

print_effect_code() {
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
    dim)
      printf "$TEXT_DIM"
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

  case "$styles" in
    path)
      styles="blue,bold"
      ;;
    command)
      styles="cyan"
      ;;
    action)
      styles="green,bold"
      ;;
    option)
      styles="yellow"
      ;;
    num)
      styles="white"
      ;;
    *)
      ;;
  esac

  IFS="," read -ra styles <<< "$styles"

  for style in "${styles[@]}"; do
    print_effect_code "$style"
  done

  printf "%s%s" "$2" "$TEXT_RESET"
}

info() {
  if [[ "$1" == "i" ]]; then
    shift
    echo "  $@"
  else
    echo "$(style "cyan" "▶") $@"
  fi
}

error() {
  echo "$(style "red" "!!") $@"
}

usage() {
  APPEND=""
  if [[ "$_CFG_LOADED" != "1" ]]; then
    SAMPLE_CMD="$(\
      echo \
        "$(style "bold" "$0")"\
        "$(style "command" "sample-config")"\
        ">"\
        "$(style "path" "~/.config/nos/config")"\
    )"
    APPEND=$(
      echo " Run the following to generate a config"
      echo "                  file:"
      printf "                  $SAMPLE_CMD"
    )
  fi

  cat <<EOF
Usage:
$(echo \
 "$(style "bold" "$0")"\
 "$(style "command" "<function>")"\
 "[$(style "option" "-optionA")"\
 "[$(style "path" "~/file")]]"\
 "[$(style "action" "action")]"
)

Options:
  $(style "option" "--config") $(style "path" "<config>")   Directly specify a config file. Ignores $(style "path" "~/.config") files in
                      that case, including $(style "path" "config.local").

  $(style "option" "--dry-run")           Does a dry run for $(style "command" "stow") and $(style "command" "os") $(style "action" "build") so no actual changes
                      are made.

  $(style "option" "-y, --yes")           Bypass any confirmation requests, i.e. for $(style "command" "os") $(style "action" "build").

$(style "dim" "Note:") $(style "command" "<function>") $(style "dim" "must always be defined first.")

Functions:
  $(style "command" "init")            Git clone or update the defined repos.

  $(style "command" "update")          Update the repos to origin/latest.

  $(style "command" "stow")            Run GNU Stow on the public and eventual private dotfiles.
    $(style "action" "public")        Stow only public.
    $(style "action" "private")       Stow only private.

  $(style "command" "os")              NixOS helper actions.
    $(style "action" "build")         Rebuild NixOS defined in the config.

  $(style "command" "auto-update")     Runs $(style "command" "update") and $(style "command" "stow"). Used by the sytemd service.

  $(style "command" "service")         Service actions.
    $(style "action" "start")
    $(style "action" "stop")
    $(style "action" "status")
    $(style "action" "log")

  $(style "command" "help")            Show this.

  $(style "command" "sample-config")   Output a sample config.$APPEND
EOF
}

missing_config() {
  error "Missing config. Generate sample:"
  info i "$(style "bold" "$0")"\
    "$(style "command" "sample-config") >"\
    "$(style "path" "~/.config/nos/config")"
}

styled_build() {
  printf "%s %s %s %s %s" "$(style "bold" "sudo")"\
    "$(style "command" "nixos-rebuild")"\
    "$(style "action" "switch")"\
    "$(style "option" "--flake")"\
    "$(style "path" "$NIXOS_PATH#$NIXOS_BUILD_HOSTNAME")"
}

sample_config() {
  cat <<EOF
STOW_TARGET=~/

# Whether to run stow during service updates.
AUTO_UPDATE_STOW=1

# Public dotfiles repo.
PUBLIC_PATH=~/configs/dotfiles
PUBLIC_REPO=git@github.com:SampleUser/dotfiles.git

# Optional repo with stuff you don't want out in public.
# Even though it's private, DON'T put any ssh keys or plain text passwords in there.
PRIVATE_PATH=~/configs/dotfiles-private
PRIVATE_REPO=git@github.com:SampleUser/dotfiles-private.git

# Optional NixOS config.
NIXOS_PATH=~/configs/nixos
NIXOS_REPO=git@github.com:SampleUser/nixos-conf.git
NIXOS_BUILD_HOSTNAME=my-nixos

# ~/.ssh/ key to be used for git. If you don't want to or can't use your regular key.
#REPO_SSH_KEY=id_ed25519.dockfiles
EOF
}
