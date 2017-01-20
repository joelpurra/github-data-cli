function errorMsg {
	echo -E "${PROJECT_PREFIX}: ERROR $@" >&2
}

function debugMsg {
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
	date -r "$1" -u +%FT%TZ
}

function getMostRecentOutputDates() {
	find "$configOutdir" -mindepth 1 -maxdepth 1 -type d -name '*-*-*' | tail -n 2 | xargs -I '{}' basename -a '{}'
}
