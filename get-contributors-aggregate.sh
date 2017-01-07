#!/usr/bin/env bash

set -e
set -u

readonly SCRIPT_NAME=$(basename "$BASH_SOURCE")
readonly HEADERS_FILE=".headers.json~"

function die {
	echo -E "${SCRIPT_NAME} fatal: $@" >&2
	exit 1
}

function fetchGithub {
	local -a fetchArgs=( "$@" )
	local url="${fetchArgs[-1]}"
	echo "$url" >&2
	unset fetchArgs[${#fetchArgs[@]}-1]
	local -a urlParts
	IFS='?' read -r -a urlParts <<< "$url"
	local urlWithCredentials="${urlParts[0]}?client_id=${GITHUB_CLIENT_ID}&client_secret=${GITHUB_CLIENT_SECRET}&${urlParts[1]:-}"
	curl --silent --header "User-Agent: ${SCRIPT_NAME}" "${fetchArgs[@]}" "$urlWithCredentials"
}

function getUTCDatestamp {
	date -u +%F
}

function getTimestampAtEpoch {
	date -r "$1" -u +%FT%TZ
}

function getNextPageLink {
	sed -n '{
		/^Link:/ {
			s/^.* <\([^>]*\)>; rel="next".*$/\1/
			p
		}
	}'
}

function getNextPageNumber {
	sed -n '{
		/^.*page=[[:digit:]][[:digit:]]*.*$/ {
			s/^.*page=\([[:digit:]][[:digit:]]*\).*$/\1/
			p
		}
	}'
}

function getArrayLength {
	jq 'arrays // [] | length'
}

function fetchPage {
	local -r outfile="$1"
	shift
	local -i pageNumber="$1"
	shift
	local -r url="$1"
	shift

	if [[ ! -s "$outfile.${pageNumber}~" ]]
	then
		local page=$(fetchGithub --dump-header "$HEADERS_FILE" "${url}?page=${pageNumber}")
		local numberOfEntries=$(echo "$page" | getArrayLength)

		if (( numberOfEntries > 0 ));
		then
			echo "$page" >"$outfile.${pageNumber}~"

			return 0;
		else
			return 1;
		fi
	else
		local numberOfEntries=$(cat "$outfile.${pageNumber}~" | getArrayLength)

		if (( numberOfEntries > 0 ));
		then
			return 0;
		else
			rm "$outfile.${pageNumber}~"

			return 1;
		fi
	fi

	return 1;
}

function fetchAllPages {
	local -r outfile="$1"
	shift
	local -r url="$1"
	shift

	local -i pageNumber=1

	while fetchPage "$outfile" "$pageNumber" "$url";
	do
		echo "$outfile.${pageNumber}~"
		pageNumber+=1
	done

	[[ -s ${outfile}.1~ ]] && { cat ${outfile}.*~ | jq --slurp '[ .[][] ]' > "$outfile"; }
}

function main {
	local -r username="$1"
	shift

	local -r timestamp=$(getUTCDatestamp)

	local rateLimitObject=$(fetchGithub "https://api.github.com/rate_limit")
	local remaining=$(echo "$rateLimitObject" | jq '.resources.core.remaining // 0')
	local reset=$(echo "$rateLimitObject" | jq '.resources.core.reset // 0')
	local resetTimestamp=$(getTimestampAtEpoch "$reset")

	if (( remaining <= 0 ));
	then
		echo "$rateLimitObject" | jq '.' >&2
		die "Hit rate limit until ${resetTimestamp}!"
	else
		echo "Have ${remaining} API calls remaining until ${resetTimestamp}" >&2
	fi

	mkdir -p "$username"

	pushd "$username" >/dev/null

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
	if [[ -z "${GITHUB_CLIENT_ID}" ]];
	then
		die "Missing GITHUB_CLIENT_ID"
	fi
	set -u

	set +u
	if [[ -z "${GITHUB_CLIENT_SECRET}" ]];
	then
		die "Missing GITHUB_CLIENT_SECRET"
	fi
	set -u

	set +u
	if [[ -z "$1" ]];
	then
		die "Missing username; provide it on the command line"
	fi
	set -u
}

checkInput "$@"

main "$@"