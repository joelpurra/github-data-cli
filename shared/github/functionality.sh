#!/usr/bin/env bash

set -e
set -u
set -o pipefail

function checkUsernameInput {
	set +u
	if [[ -z "$1" ]];
	then
		die "Missing username; provide it on the command line"
	fi
	set -u

	return 0
}

function checkRepositoryInput {
	# NOTE: repository is not used much yet.
	set +u
	if [[ -z "$1" ]];
	then
		return 1
	else
		return 0
	fi
	set -u
}

# TODO: use getopts or similar?
checkUsernameInput "$@" && readonly configUsername="$1" && shift

# TODO: use getopts or similar?
checkRepositoryInput "$@" && readonly configRepository="$1" && shift

readonly configOutdir="${CONFIG_OUTPUT_PREFIX}/${configUsername}"

readonly configOutdirDaily="${configOutdir}/${executionStartTimestamp}"
