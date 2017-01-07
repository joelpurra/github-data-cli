#!/usr/bin/env bash

set -e
set -u
set -o pipefail

declare PROJECT_PREFIX="ghd"

readonly configOutputPrefix="output";
readonly executionStartTimestamp=$(getUTCDatestamp)
