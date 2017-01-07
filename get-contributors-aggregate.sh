#!/usr/bin/env bash

set -e
set -u

readonly SCRIPT_NAME=$(basename "$BASH_SOURCE")
readonly outputPrefix="output";

source "functions/basic.sh"
source "functions/json.sh"
source "functions/github.sh"

function main {
	local -r username="$1"
	shift

	local -r timestamp=$(getUTCDatestamp)

	local -r outdir="${outputPrefix}/${username}"

	mkdir -p "$outdir"

	pushd "$outdir" >/dev/null

		mkdir -p "$timestamp"

			pushd "$timestamp" >/dev/null

			fetchAllPages "repositories.json" "https://api.github.com/users/${username}/repos"

			cat "repositories.json" | jq 'map(select((.private or .fork or (.mirror_url | type) != "null") | not))' >"sources.json"

			mkdir -p "contributors"

			pushd "contributors" >/dev/null

			local name
			local contributors

			while read name;
			do
				read contributors;
				local contributorsOutfile="${name}.json"

				[[ -s "$contributorsOutfile" ]] || fetchGithub "$contributors" > "$contributorsOutfile"
			done < <(cat "../sources.json" | jq --raw-output 'map(.name, .contributors_url) | .[]')

			local aggregatedContributorsOutfile="../contributors.json"

			# Seems jq acts differently if using `cat *.json` versus `jq --slurp '...' *.json`.
			jq --slurp 'map(map({ login, contributions }) | .[]) | group_by(.login) | map({ login: .[0].login, contributions: (map(.contributions) | add) }) | sort_by(.contributions)' *.json > "$aggregatedContributorsOutfile"

			<"$aggregatedContributorsOutfile" jq '.'

			popd >/dev/null

		popd >/dev/null

	popd >/dev/null
}

function checkInput {
	set +u
	if [[ -z "$1" ]];
	then
		die "Missing username; provide it on the command line"
	fi
	set -u
}

checkInput "$@"

checkGithubPrerequisites

main "$@"
