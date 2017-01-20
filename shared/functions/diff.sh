function getJsonForDiffing() {
	local -r filename="$1"
	shift
	local -r from="$1"
	shift
	local -r to="$1"
	shift

	local -r fromPath="${configOutdir}/${from}/${filename}"
	local -r toPath="${configOutdir}/${to}/${filename}"

	[[ ! -f "$fromPath" ]] && die "Could not find diff 'from' path:" "$fromPath"

	[[ ! -f "$toPath" ]] && die "Could not find diff 'to' path:" "$toPath"

	cat "$fromPath" "$toPath"
}

function diffJsonTwoArraysOfValuePairObjectsArrays {
	jq --slurp 'def objectValuePairToKeyValue: . | to_entries | [ { key: .[0].value, value: .[1].value } ] | from_entries; def objectValuePairToKeyValueArrayToObject: reduce .[] as $entry ({}; . + ($entry | objectValuePairToKeyValue)); (.[0] | objectValuePairToKeyValueArrayToObject) as $left | (.[1] | objectValuePairToKeyValueArrayToObject) as $right | $left + $right | keys | reduce .[] as $key ({}; . + { ($key): (($right[$key] // 0) - ($left[$key] // 0)) }) | with_entries(select(.value != 0))'
}

function diffDateJson {
	local -r filename="$1"
	shift
	set +u
	local from="$1"
	local to="$2"
	set -u

	if [[ -z "$from" || -z "$to" ]];
	then
		local -a mostRecentOutputDates=($(getMostRecentOutputDates))
		from="${mostRecentOutputDates[0]}"
		to="${mostRecentOutputDates[1]}"
	fi

	echo "From ${from} to ${to}"

	# getJsonForDiffing | xargs diff -u
	getJsonForDiffing "$filename" "$from" "$to" | diffJsonTwoArraysOfValuePairObjectsArrays
}
