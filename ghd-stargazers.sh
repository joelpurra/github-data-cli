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
	pushd "$configOutdir" >/dev/null
			pushd "$executionStartTimestamp" >/dev/null

			fetchGithubRepositories "$configUsername"
			extractGithubSources

			mkdir -p "stargazers"

			pushd "stargazers" >/dev/null
				local name
				local stargazers

				while read name;
				do
					read stargazers;
					local stargazersOutfile="${name}.json"

					[[ -s "$stargazersOutfile" ]] || fetchGithub "$stargazers" > "$stargazersOutfile"
				done < <(cat "../sources.json" | jq --raw-output 'map(.name, .stargazers_url) | .[]')

				local aggregatedStargazersOutfile="../stargazers.json"

				# Seems jq acts differently if using `cat *.json` versus `jq --slurp '...' *.json`.
				jq --slurp 'map(map({ login }) | .[]) | group_by(.login) | map({ login: .[0].login, stars: length }) | sort_by(.stars, .login)' *.json > "$aggregatedStargazersOutfile"

				<"$aggregatedStargazersOutfile" jq '.'
			popd >/dev/null
		popd >/dev/null
	popd >/dev/null
}

main "$@"
