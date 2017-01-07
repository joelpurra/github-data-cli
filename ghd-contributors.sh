#!/usr/bin/env bash

set -e
set -u
set -o pipefail

source "${BASH_SOURCE%/*}/shared/functions.sh"
source "${BASH_SOURCE%/*}/shared/functionality.sh"
source "${BASH_SOURCE%/*}/shared/github/functionality.sh"

function main {
	pushd "$configOutdir" >/dev/null
			pushd "$executionStartTimestamp" >/dev/null

			fetchGithubRepositories "$configUsername"
			extractGithubSources

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

main "$@"
