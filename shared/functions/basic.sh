function errorMsg {
	echo -E "${PROJECT_PREFIX}: ERROR $@" >&2
}

function debugMsg {
	set +u
	if [[ "$GHD_DEBUG" != "1" ]];
	then
		return 0
	fi
	set -u

	echo -E "${PROJECT_PREFIX}: DEBUG $@" >&2
}

function die {
	errorMsg "fatal" "$@"
	exit 1
}

function getUTCDatestamp {
	date -u +%F
}

function getTimestampAtEpoch {
	if date -r "1516963224" &>/dev/null;
	then
		date -r "$1" -u +%FT%TZ
	else
		date --date "@${1}" -u +%FT%TZ
	fi
}

function getMostRecentOutputDates() {
	find "$configOutdir" -mindepth 1 -maxdepth 1 -type d -name '*-*-*' | tail -n 2 | xargs -I '{}' basename -a '{}'
}
