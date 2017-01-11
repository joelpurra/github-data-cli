function die {
	echo -E "${PROJECT_PREFIX} fatal: $@" >&2
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
