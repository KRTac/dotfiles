public_path_check() {
  if [[ -z "$PUBLIC_PATH" ]]; then
    error "Public dotfiles path not specified."
    exit 1
  fi
}

init_repos() {
  network_or_die

  info "Initiating or updating repos"

  public_path_check

  if [[ -n "$PUBLIC_REPO" ]]; then
    info "Public repo..."
    init_repo "$PUBLIC_PATH" "$PUBLIC_REPO"
  fi

  if [[ -n "$PRIVATE_PATH" && -n "$PRIVATE_REPO" ]]; then
    info "Private repo..."
    init_repo "$PRIVATE_PATH" "$PRIVATE_REPO"
  fi

  if [[ -n "$NIXOS_PATH" && -n "$NIXOS_REPO" ]]; then
    info "NixOS repo..."
    init_repo "$NIXOS_PATH" "$NIXOS_REPO"
  fi
}

init_repo() {
  dir="$1"
  repoUrl="$2"

  if [[ -z "$repoUrl" ]]; then
    error "Repo not specified for $(style "path" "$dir")"
    exit 1
  fi

  if [[ ! -e "$dir" ]]; then
    info "Destination directory doesn't exist."
    info i "Creating $(style "path" "$dir")"
    mkdir -p "$dir"
  fi

  if [[ ! -d "$dir" ]]; then
    error "Not a directory: $(style "path" "$dir")"
    exit 1
  fi

  dir="$(realpath "$dir")"

  if [[ "$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)" == "$dir" ]]; then
    info "Git repository detected in $(style 'path' "$dir")"
    info i "Fast-forwarding the repo if possible."

    repo_to_latest "$dir"
  else
    info "Cloning repo from"\
      "$(style "path" "$repoUrl") into"\
      "$(style "path" "$dir")"
    _git "$dir" clone "$repoUrl" "$dir"
  fi
}

latest_all() {
  network_or_die

  info "Updating repos"

  public_path_check

  if [[ -n "$PUBLIC_REPO" ]]; then
    info "Public repo..."
    repo_to_latest "$PUBLIC_PATH"
  fi

  if [[ -n "$PRIVATE_PATH" && -n "$PRIVATE_REPO" ]]; then
    info "Private repo..."
    repo_to_latest "$PRIVATE_PATH"
  fi

  if [[ -n "$NIXOS_PATH" && -n "$NIXOS_REPO" ]]; then
    info "NixOS repo..."
    repo_to_latest "$NIXOS_PATH"
  fi
}

stow_all() {
  public_path_check

  info "Stowing public..."
  run_stow "$PUBLIC_PATH"

  if [[ -n "$PRIVATE_PATH" ]]; then
    info "Stowing private..."
    run_stow "$PRIVATE_PATH"
  fi
}

repo_to_latest() {
  _git "$1" pull --ff-only
}

run_stow() {
  if [[ -z "$STOW_TARGET" ]]; then
    error "$(style "green,bold" "STOW_TARGET") not set, skipping stow..."
    return
  fi

  if [[ -z "$_WITH_STOW" ]]; then
    error "$(style "green,bold" "stow") command not found."
    info i "Install GNU Stow to symlink the files to the STOW_TARGET directory."
    return
  fi

  if [[ ! -d "$STOW_TARGET" ]]; then
    info "Stow target doesn't exist."
    info i "Creating $(style "path" "$STOW_TARGET")"
    mkdir -p "$STOW_TARGET"
  fi

  if [[ -n "$STOW_DRY_RUN" ]]; then
    info "Source: $(style "path" "$1")"
    info i "Target: $(style "path" "$STOW_TARGET")"
    info i "Dry run only, no changes applied."
    stow -d "$1" -t "$STOW_TARGET" --no-folding -n -v .
  else
    info "Source: $(style "path" "$1")"
    info i "Target: $(style "path" "$STOW_TARGET")"
    stow -d "$1" -t "$STOW_TARGET" --no-folding .
  fi
}

_git() {
  repoPath=$1
  shift

  if [[ -n "$REPO_SSH_KEY" ]]; then
    git\
      -C "$repoPath"\
      -c "core.sshCommand=ssh -i $HOME/.ssh/$REPO_SSH_KEY -F /dev/null"\
      "$@"
  else
    git -C "$repoPath" "$@"
  fi
}
