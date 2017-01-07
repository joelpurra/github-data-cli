#!/usr/bin/env bash

set -e
set -u
set -o pipefail

source "${BASH_SOURCE%/*}/functions/basic.sh"
source "${BASH_SOURCE%/*}/functions/json.sh"
source "${BASH_SOURCE%/*}/github/github.sh"
