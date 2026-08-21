source "$(dirname "${BASH_SOURCE[0]}")/output.sh"

network_or_die() {
  timeout_sec=20

  timeout "$timeout_sec" bash -c '
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
  elif (( status > 0 && status <= (timeout_sec + 2) )); then
    echo "  Great success, we got network."
  elif (( status != 0 )); then
    error "Error while waiting for network. Exit code: $(style "yellow" "$status")."
    exit 1
  fi
}
