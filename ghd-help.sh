#!/usr/bin/env bash

set -e
set -u
set -o pipefail

source "${BASH_SOURCE%/*}/shared/functions.sh"
source "${BASH_SOURCE%/*}/shared/functionality.sh"

function main {
	local -r SOURCE_FOLDER="${BASH_SOURCE%/*}";

	echo "Usage: ${PROJECT_PREFIX} <action>"
	echo "Source folder: ${SOURCE_FOLDER}"
	echo "Actions available in the source folder: "

	while IFS= read -r -d '' file;
	do
		local filename="$(basename -s ".sh" -a "$file")"
		local actionName="${filename#${PROJECT_PREFIX}-}"
		echo "  ${actionName}"
	done < <(find "$SOURCE_FOLDER" -mindepth 1 -maxdepth 1 -type f -name "${PROJECT_PREFIX}-*.sh" -print0)
}

main "$@"
