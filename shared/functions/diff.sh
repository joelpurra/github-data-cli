function getJsonForDiffing() {
	local filename="$1"
	shift
	local from="$1"
	shift
	local to="$1"
	shift

	cat "${configOutdir}/${from}/${filename}" "${configOutdir}/${to}/${filename}"
}

function diffJsonTwoArraysOfValuePairObjectsArrays {
	jq --slurp 'def objectValuePairToKeyValue: . | to_entries | [ { key: .[0].value, value: .[1].value } ] | from_entries; def objectValuePairToKeyValueArrayToObject: reduce .[] as $entry ({}; . + ($entry | objectValuePairToKeyValue)); (.[0] | objectValuePairToKeyValueArrayToObject) as $left | (.[1] | objectValuePairToKeyValueArrayToObject) as $right | $left + $right | keys | reduce .[] as $key ({}; . + { ($key): ($right[$key] - $left[$key]) }) | with_entries(select(.value != 0))'
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
