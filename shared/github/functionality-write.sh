#!/usr/bin/env bash

set -e
set -u
set -o pipefail

mkdir -p "$configOutdir"

mkdir -p "${configOutdir}/${executionStartTimestamp}"