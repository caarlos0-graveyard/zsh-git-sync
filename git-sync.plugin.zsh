#!/bin/zsh
_log() {
  echo -e "-----> $*"
}

_prefixed() {
  sed -e "s/^/       /"
}

_prune() {
  local remote="$1"
  _log "Pruning $remote..."
  git remote prune "$remote" | _prefixed
}

_merge_locally() {
  local remote="$1"
  local branch="$2"
  _log "Merging $remote/$branch locally..."
  git fetch "$remote" | _prefixed
  git merge "$remote/$branch" | _prefixed
}

_push_to_fork() {
  local remote="$1"
  local branch="$2"
  if ! [ "$remote" = "origin" ]; then
    _log "Pushing it to origin/$branch..."
    git push origin "$branch" | _prefixed
  fi
}

_nuke() {
  git branch -d "$1" || true | _prefixed
  git push origin :"$1" || true | _prefixed
}

_remove_merged() {
  _log "Removing merged branches..."
  local merged="$(git branch --merged | grep -v "^\*" | grep -v 'master')"
  echo "$merged" | while read branch; do
    [[ "$branch" = "" ]] || _nuke "$branch"
  done
}

git-sync() {
  local branch=$(git symbolic-ref --short HEAD)
  local remote=$(git remote | grep upstream || echo "origin")
  _prune "$remote"
  _merge_locally "$remote" "$branch"
  _push_to_fork "$remote" "$branch"
  _remove_merged
  _log "All done!"
}
