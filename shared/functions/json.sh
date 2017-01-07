function getArrayLength {
	jq 'arrays // [] | length'
}
