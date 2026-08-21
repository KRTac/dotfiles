source "$(dirname "${BASH_SOURCE[0]}")/output.sh"

NETWORK_TIMEOUT_SEC=20

network_or_die() {
  timeout "$NETWORK_TIMEOUT_SEC" bash -c '
    slept=0
    until curl -fs --max-time 5 https://example.com >/dev/null; do
      if (( slept == 0 )); then
        echo "  Waiting for a network connection..."
      fi

      if (( slept == 10 )); then
        echo "  Still waiting..."
      fi

      if (( slept == 15 )); then
        echo "  ..."
      fi

      sleep 1
      ((slept += 1))
    done
    exit "$slept"
  '
  status=$?

  if (( status == 124 )); then
    error "No network connection. Exiting..."
    exit 1
  elif (( status > 0 && status <= (NETWORK_TIMEOUT_SEC + 2) )); then
    echo "  Great success, we got network."
  elif (( status != 0 )); then
    error "Error while waiting for network. Exit code: $(style "blue" "$status")."
    exit 1
  fi
}

stow_or_die() {
  if [[ "$_WITH_STOW" != "1" ]]; then
    info "Can't locate the stow command."
    exit 1
  fi
}
