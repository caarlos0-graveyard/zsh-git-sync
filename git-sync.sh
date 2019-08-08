#!/bin/sh
_log() {
  echo "-----> $*"
}

_prefixed() {
  sed -e "s/^/       /"
}

_prune() {
  # shellcheck disable=SC2039
  local remote
  remote="$1"
  _log "Pruning $remote..."
  git remote prune "$remote" | _prefixed
}

_merge_locally() {
  # shellcheck disable=SC2039
  local branch remote
  remote="$1"
  branch="$2"
  _log "Merging $remote/$branch locally..."
  git fetch "$remote" | _prefixed
  git merge --no-edit "$remote/$branch" | _prefixed
}

_push_to_fork() {
  # shellcheck disable=SC2039
  local branch remote
  remote="$1"
  branch="$2"
  if ! [ "$remote" = "origin" ]; then
    _log "Pushing it to origin/$branch..."
    git push origin "$branch" | _prefixed
  fi
}

# shellcheck disable=SC2039
git-delete-local-merged() {
  # shellcheck disable=SC2039
  local branches
  _log "Removing merged branches..."
  branches="$(git branch --merged | grep -v "^\*" | grep -v 'master' | tr -d '\n')"
  [ -n "$branches" ] && echo "$branches" | xargs git branch -d

  _log "Removing squashed and merged branches..."
  git for-each-ref refs/heads/ "--format=%(refname:short)" | while read -r branch; do
    base="$(git merge-base master "$branch")"
    hash="$(git rev-parse "$branch^{tree}")"
    commit="$(git commit-tree "$hash" -p "$base" -m _)"
    [[ $(git cherry master "$commit") == "-"* ]] && git branch -D "$branch"
  done
}

# shellcheck disable=SC2039
git-sync() {
  # shellcheck disable=SC2039
  local branch remote
  branch=$(git symbolic-ref --short HEAD)
  remote=$(git remote | grep upstream || echo "origin")
  _prune "$remote"
  _merge_locally "$remote" "$branch"
  _push_to_fork "$remote" "$branch"
  git branch -u "$remote/$branch"
  git-delete-local-merged
  _log "All done!"
}
