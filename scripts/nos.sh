#!/usr/bin/env bash


_NIXOS_BIN="/run/current-system/sw/bin"

if [[ -d "$_NIXOS_BIN" ]]; then
  PATH="$_NIXOS_BIN:$PATH"
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/output.sh"
source "$SCRIPT_DIR/lib/repos.sh"

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

function="$1"
shift

ARGS_REST=()

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

CFG_PATH="$HOME/.config/nos/config"
CFG_OVERRIDE_PATH="$HOME/.config/nos/config.local"
AUTO_UPDATE_STOW=

if [[ -f "$CFG_PATH" ]]; then
  info "Sourcing configuration from $(style "path" "$CFG_PATH")"
  source "$CFG_PATH"
  _CFG_LOADED=1
fi

if [[ -f "$CFG_OVERRIDE_PATH" ]]; then
  info "Local config detected in $(style "path" "$CFG_OVERRIDE_PATH")"
  source "$CFG_OVERRIDE_PATH"
  _CFG_LOADED=1
fi

if [[ -z "$_CFG_LOADED" ]]; then
  missing_config
  exit 1
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
    stow_all
    ;;
  auto-update)
    latest_all

    if [[ "$AUTO_UPDATE_STOW" == "1" ]]; then
      stow_all
    fi
    ;;
  service)
    if [[ ${#ARGS_REST[@]} -eq 0 ]]; then
      error "No service action specified."
      exit 1
    fi

    if [[ "${ARGS_REST[0]}" == "start" ]]; then
      info "Starting service timer..."
      systemctl --user start nos-auto-update.timer
    elif [[ "${ARGS_REST[0]}" == "stop" ]]; then
      info "Stopping service timer..."
      systemctl --user stop nos-auto-update.timer
    else
      error "Unknown service action $(style "green" "${ARGS_REST[0]}")."
      exit 1
    fi
    ;;
  help)
    usage
    ;;
  *)
    echo "Unknown function: $function" >&2
    exit 1
    ;;
esac
