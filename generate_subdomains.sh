#!/bin/bash

# Function to display help usage
show_help() {
	echo "Usage: $0 -d <domain> -f <file>"
	echo ""
	echo "Options:"
	echo " -d <domain>       The root domain (e.g., example.com)"
	echo " -f <file>         Path to the subdomain text file"
	echo " -o <output_file>  (Optional) Path to save the results"
	echo " -h                Show this help message"
	exit 0
}

# Initialze variables to ensure they are empty
DOMAIN=""
FILE=""
OUTPUT_FILE=""

# Parse command line options
# getopts "d:f:h": This tells Bash to look for -d, -f, o, and -h. The colons (:) mean that -d,-f and -o require a value right after them.
# ${OPTARG}: This is a built-in variable that captures the value passed to the flag.
while getopts "d:f:o:h" opt; do
	case "${opt}" in
		d) DOMAIN="${OPTARG}" ;;
		f) FILE="${OPTARG}" ;;
		o) OUTPUT_FILE="${OPTARG}" ;;
		h) show_help ;;
		*) show_help ;; # This Triggers if there are invalid flags
	esac
done

# Validate that both flags were provided
if [[ -z "${DOMAIN}" || -z "${FILE}" ]]; then
	echo "Error: Both -d <domain> and -f <file> are required." >&2
	echo "Use -h for help." >&2
	exit 1
fi

# Clear or create the output file if the user specified one
if [[ -n "${OUTPUT_FILE}" ]]; then
	touch "${OUTPUT_FILE}" 2>/dev/null
	if [[ $? -ne 0 ]]; then
		echo "Error: Cannot write to output '{OUTPUT_FILE}'." >&2
		exit 1
	fi
fi

# Process the file
while read -r subdomain; do
	# Skip empty lines
	[[ -z "${subdomain}" ]] && continue

	FULL_DOMAIN="${subdomain}.${DOMAIN}"

	# If output file is provided, append to it. Othewise, print to screen
	if [[ -n ${OUTPUT_FILE} ]]; then
		echo "${FULL_DOMAIN}" >> "$OUTPUT_FILE"
	else
		echo "${FULL_DOMAIN}"
	fi
done < "${FILE}"

# Print a success message to stderr if saving to a file
if [[ -n "${OUTPUT_FILE}" ]]; then
	echo "Success! Results saved to ${OUTPUT_FILE}" >&2
fi
