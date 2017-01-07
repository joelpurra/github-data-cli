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