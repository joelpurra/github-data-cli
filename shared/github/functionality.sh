#!/usr/bin/env bash

set -e
set -u
set -o pipefail

function checkInput {
	set +u
	if [[ -z "$1" ]];
	then
		die "Missing username; provide it on the command line"
	fi
	set -u
}

checkInput "$@"

readonly configUsername="$1"
shift

readonly configOutdir="${configOutputPrefix}/${configUsername}"

readonly configOutdirDaily="${configOutdir}/${executionStartTimestamp}"
