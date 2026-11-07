#!/bin/sh
set -eu

case "${GITHUB_TOKEN:-}" in
  ""|*[!A-Za-z0-9_]*)
    echo "GITHUB_TOKEN: empty or not valid" >&2
    exit 1
    ;;
esac

case "${GIT_USER_NAME:-}" in
  ""|*[!A-Za-z0-9._[:space:]@-]*)
    echo "GIT_USER_NAME: empty or not valid" >&2
    exit 1
    ;;
esac

case "${GIT_USER_EMAIL:-}" in
  ""|*[!A-Za-z0-9._@+@-]*)
    echo "GIT_USER_EMAIL: empty or not valid" >&2
    exit 1
    ;;
esac

case "${GIT_DEFAULT_BRANCH:-}" in
  ""|*[!A-Za-z0-9._/@-]*)
    echo "GIT_DEFAULT_BRANCH: empty or not valid" >&2
    exit 1
    ;;
esac

chown root:root /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

git config --global user.name  "${GIT_USER_NAME:-}"
git config --global user.email "${GIT_USER_EMAIL:-}"
git config --global init.defaultBranch "${GIT_DEFAULT_BRANCH:-main}"
git config --global credential.helper '!f() { echo "username=x-access-token"; echo "password='${GITHUB_TOKEN}'"; }; f'

exec "$@"
