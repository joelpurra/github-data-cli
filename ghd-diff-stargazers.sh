#!/usr/bin/env bash

set -e
set -u
set -o pipefail

source "${BASH_SOURCE%/*}/shared/functions.sh"
source "${BASH_SOURCE%/*}/shared/functionality.sh"
source "${BASH_SOURCE%/*}/shared/github/functionality.sh"

function main {
	diffDateJson "stargazers.json" "$@"
}

main "$@"
