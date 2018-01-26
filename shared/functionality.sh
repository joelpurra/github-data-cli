#!/usr/bin/env bash

set -e
set -u
set -o pipefail

declare PROJECT_PREFIX="ghd"

readonly CONFIG_PREFIX="${HOME}/.ghd";
readonly CONFIG_OUTPUT_PREFIX="${CONFIG_PREFIX}/output";
readonly CONFIG_AUTHORIZATION_FILE="${CONFIG_PREFIX}/authorization.json"
readonly executionStartTimestamp=$(getUTCDatestamp)
