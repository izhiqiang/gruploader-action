#!/bin/bash -eux


check_empty "GRUPLOADER_COMMAND" "${GRUPLOADER_COMMAND}"

INPUT_EXTRA_FILES="${INPUT_EXTRA_FILES:-""}"
check_empty "INPUT_EXTRA_FILES" "${INPUT_EXTRA_FILES}"

# Convert comma separated upload file names into arrays
FILES_TO_UPLOAD=$(echo "$INPUT_EXTRA_FILES" | tr ',' ' ')
# Verify if the file exists, and report an error if any file does not exist
for FILE in $FILES_TO_UPLOAD; do
  if [ ! -f  "${FILE}" ]; then
    error_log "${FILE} file does not exist !!!"
    exit 1
  fi
done

#Upload the file file
for FILE in $FILES_TO_UPLOAD; do
  if [ -f  "${FILE}" ]; then
    debug_log "Uploading ${FILE} file to the repository ${INPUT_REPOSITORY} under the ${INPUT_TAG} tag. Retry attempt: ${INPUT_RETRY}. Force push is enabled (${INPUT_OVERWRITE})."
    ${GRUPLOADER_COMMAND} -f ${FILE}
  fi
done