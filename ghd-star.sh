#!/usr/bin/env bash

set -e
set -u
set -o pipefail

source "${BASH_SOURCE%/*}/shared/functions.sh"
source "${BASH_SOURCE%/*}/shared/functionality.sh"
source "${BASH_SOURCE%/*}/shared/github/functionality.sh"
source "${BASH_SOURCE%/*}/shared/github/functionality-online.sh"
source "${BASH_SOURCE%/*}/shared/github/functionality-write.sh"

function main {
	starGithubRepository "$configUsername" "$configRepository"
}

main "$@"
