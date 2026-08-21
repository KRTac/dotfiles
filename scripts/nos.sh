#!/usr/bin/env bash


_NIXOS_BIN="/run/current-system/sw/bin"

if [[ -d "$_NIXOS_BIN" ]]; then
  PATH="$_NIXOS_BIN:$PATH"
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/util.sh"
source "$SCRIPT_DIR/lib/repos.sh"

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

function="$1"
shift

ARGS_REST=()
_STOW_DRY_RUN=

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for $1"
        exit 1
      fi

      CFG_PATH="$2"
      shift 2
      ;;
    --dry-run)
      _STOW_DRY_RUN=1
      shift
      ;;
    *)
      ARGS_REST+=("$1")
      shift
      ;;
  esac
done

if [[ "$function" == "sample-config" ]]; then
  sample_config
  exit 0
fi

if [[ -f "$CFG_PATH" ]]; then
  CFG_PATH="$(realpath "$CFG_PATH")"
else
  CFG_PATH="$HOME/.config/nos/config"
fi

if [[ -f "$CFG_PATH" ]]; then
  info "Sourcing configuration from $(style "path" "$CFG_PATH")"
  source "$CFG_PATH"
  _CFG_LOADED=1
fi

CFG_OVERRIDE_PATH="$HOME/.config/nos/config.local"
AUTO_UPDATE_STOW=

if [[ -f "$CFG_OVERRIDE_PATH" ]]; then
  info "Local config detected in $(style "path" "$CFG_OVERRIDE_PATH")"
  source "$CFG_OVERRIDE_PATH"
  _CFG_LOADED=1
fi

if [[ -z "$_CFG_LOADED" ]]; then
  missing_config
  exit 1
fi

if [[ "$_STOW_DRY_RUN" != "1" ]]; then
  _STOW_DRY_RUN="${STOW_DRY_RUN:-}"
fi

if [[ -n "$STOW_TARGET" ]]; then
  STOW_TARGET="$(realpath "$STOW_TARGET")"
fi

if command -v stow &>/dev/null; then
  _WITH_STOW=1
else
  _WITH_STOW=
fi

case "$function" in
  init)
    init_repos
    ;;
  update)
    latest_all
    ;;
  stow)
    stow_or_die

    if [[ ${#ARGS_REST[@]} -eq 0 ]]; then
      stow_all
      exit
    fi

    case "${ARGS_REST[0]}" in
      public)
        stow_public
        ;;
      private)
        stow_private
        ;;
      *)
        error "Unknown repo $(style "action" "${ARGS_REST[0]}")."
        exit 1
        ;;
    esac
    ;;
  auto-update)
    latest_all

    if [[ "$AUTO_UPDATE_STOW" != "1" ]]; then
      info "Stow disabled for $(style "action" "auto-update")."
      info i "Set AUTO_UPDATE_STOW=1 inside your config to enable it."
      exit 0
    fi

    stow_or_die
    stow_all
    ;;
  service)
    if [[ ${#ARGS_REST[@]} -eq 0 ]]; then
      error "No service action specified."
      exit 1
    fi

    case "${ARGS_REST[0]}" in
      start)
        info "Starting service timer..."
        systemctl --user start nos-auto-update.timer
        ;;
      stop)
        info "Stopping service timer..."
        systemctl --user stop nos-auto-update.timer
        ;;
      status)
        systemctl --user status nos-auto-update.service
        ;;
      log)
        journalctl --user -f -u nos-auto-update.service
        ;;
      *)
        error "Unknown service action $(style "action" "${ARGS_REST[0]}")."
        exit 1
        ;;
    esac
    ;;
  help)
    usage
    ;;
  *)
    echo "Unknown function $(style "command" "$function")" >&2
    exit 1
    ;;
esac
