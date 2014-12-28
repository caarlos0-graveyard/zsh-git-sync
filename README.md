# zsh-git-sync [![Build Status](https://travis-ci.org/caarlos0/zsh-git-sync.svg?branch=master)](https://travis-ci.org/caarlos0/zsh-git-sync)

A zsh plugin to sync git repositories and clean them up.

## Define `sync`

- prune `origin` or `upstream`;
- merge `upstream` into current branch;
- push merged branch to fork (`origin`);
- remove merged branches.

## Install

```sh
antigen bundle caarlos0/zsh-git-sync
```

## Usage

```sh
git-sync
```

Or, go ahead and alias it:

```sh
git config --global alias.sync '!zsh -ic git-sync'
```

Then

```sh
git sync
```
