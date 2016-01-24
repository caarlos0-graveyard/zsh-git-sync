#!/bin/sh
_log() {
  echo "-----> $*"
}

_prefixed() {
  sed -e "s/^/       /"
}

_prune() {
  local remote
  remote="$1"
  _log "Pruning $remote..."
  git remote prune "$remote" | _prefixed
}

_merge_locally() {
  local branch remote
  remote="$1"
  branch="$2"
  _log "Merging $remote/$branch locally..."
  git fetch "$remote" | _prefixed
  git merge "$remote/$branch" | _prefixed
}

_push_to_fork() {
  local branch remote
  remote="$1"
  branch="$2"
  if ! [ "$remote" = "origin" ]; then
    _log "Pushing it to origin/$branch..."
    git push origin "$branch" | _prefixed
  fi
}

git-delete-local-merged() {
  local branches
  _log "Removing merged branches..."
  branches="$(git branch --merged | grep -v "^\*" | grep -v 'master' | tr -d '\n')"
  [ ! -z "$branches" ] && echo "$branches" | xargs git branch -d
}

git-sync() {
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
