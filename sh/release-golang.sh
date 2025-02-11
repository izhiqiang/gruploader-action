#!/bin/bash -eux


check_empty "GRUPLOADER_COMMAND" "${GRUPLOADER_COMMAND}"

INPUT_EXTRA_FILES="${INPUT_EXTRA_FILES:-""}"

#Binary file
INPUT_BIN_NAME="${INPUT_BIN_NAME:-$(basename $(pwd))}"
#Compress the specified files in the root directory as well
INPUT_GOOS="${INPUT_GOOS:-$(go env GOHOSTOS)}"
INPUT_GOARCH="${INPUT_GOARCH:-$(go env GOHOSTARCH)}"
INPUT_BUILD_FLAGS="${INPUT_BUILD_FLAGS:-""}"
INPUT_GOAMD64="${INPUT_GOAMD64:-""}"
INPUT_GOARM="${INPUT_GOARM:-""}"
INPUT_GOMIPS="${INPUT_GOMIPS:-""}"
INPUT_LDFLAGS="${INPUT_LDFLAGS:-""}"

check_empty "INPUT_BIN_NAME" "${INPUT_BIN_NAME}"
check_empty "INPUT_GOOS" "${INPUT_GOOS}"
check_empty "INPUT_GOARCH" "${INPUT_GOARCH}"


if [ ! -z "${INPUT_GOAMD64}" ]; then
  if [[ "${INPUT_GOARCH}" =~ amd64 ]]; then
    GOAMD64_FLAG="${INPUT_GOAMD64}"
  else
    echo "GOAMD64 should only be use with amd64 arch." >>/dev/stderr
    GOAMD64_FLAG=""
  fi
else
  if [[ "${INPUT_GOARCH}" =~ amd64 ]]; then
    GOAMD64_FLAG="v1"
  else
    GOAMD64_FLAG=""
  fi
fi

# fulfill GOARM option
if [ ! -z "${INPUT_GOARM}" ]; then
  if [[ "${INPUT_GOARCH}" =~ arm ]]; then
    GOARM_FLAG="${INPUT_GOARM}"
  else
    echo "GOARM should only be use with arm arch." >>/dev/stderr
    GOARM_FLAG=""
  fi
else
  if [[ "${INPUT_GOARCH}" =~ arm ]]; then
    GOARM_FLAG=""
  else
    GOARM_FLAG=""
  fi
fi

# fulfill GOMIPS option
if [ ! -z "${INPUT_GOMIPS}" ]; then
  if [[ "${INPUT_GOARCH}" =~ mips ]]; then
    GOMIPS_FLAG="${INPUT_GOMIPS}"
  else
    echo "GOMIPS should only be use with mips arch." >>/dev/stderr
    GOMIPS_FLAG=""
  fi
else
  if [[ "${INPUT_GOARCH}" =~ mips ]]; then
    GOMIPS_FLAG=""
  else
    GOMIPS_FLAG=""
  fi
fi


EXT=''
if [ ${INPUT_GOOS} == 'windows' ]; then
  EXT='.exe'
fi

BUILD_ARTIFACTS_FOLDER=build-artifacts-$(date +%s)
mkdir -p ${BUILD_ARTIFACTS_FOLDER}
GOAMD64=${GOAMD64_FLAG} GOARM=${GOARM_FLAG} GOMIPS=${GOMIPS_FLAG} GOOS=${INPUT_GOOS} GOARCH=${INPUT_GOARCH} go build -o ${BUILD_ARTIFACTS_FOLDER}/${INPUT_BIN_NAME}${EXT} ${INPUT_BUILD_FLAGS} -ldflags "${INPUT_LDFLAGS}"


if [ ! -z "${INPUT_EXTRA_FILES}" ]; then
  cp -r ${INPUT_EXTRA_FILES} ${BUILD_ARTIFACTS_FOLDER}/
fi

cd ${BUILD_ARTIFACTS_FOLDER}

RELEASE_ASSET_NAME=${INPUT_BIN_NAME}-${INPUT_TAG}-${INPUT_GOOS}-${INPUT_GOARCH}
if [ ! -z "${INPUT_GOAMD64}" ]; then
  RELEASE_ASSET_NAME=${INPUT_BIN_NAME}-${INPUT_TAG}-${INPUT_GOOS}-${INPUT_GOARCH}-${INPUT_GOAMD64}
fi
if [ ! -z "${INPUT_GOARM}" ] && [[ "${INPUT_GOARCH}" == 'arm' ]]; then
  RELEASE_ASSET_NAME=${INPUT_BIN_NAME}-${INPUT_TAG}-${INPUT_GOOS}-${INPUT_GOARCH}v${INPUT_GOARM}
fi
if [ ! -z "${INPUT_GOMIPS}" ] && [[ "${INPUT_GOARCH}" -eq 'mips' || "${INPUT_GOARCH}" -eq 'mipsle' || "${INPUT_GOARCH}" -eq 'mips64' || "${INPUT_GOARCH}" -eq 'mips64le' ]]; then
  RELEASE_ASSET_NAME=${INPUT_BIN_NAME}-${INPUT_TAG}-${INPUT_GOOS}-${INPUT_GOARCH}-${INPUT_GOMIPS}
fi

if [ ${INPUT_GOOS} == 'windows' ]; then
  COMPRESSION_NAME="${RELEASE_ASSET_NAME}.zip"
  zip -vr "${COMPRESSION_NAME}" *
else
  COMPRESSION_NAME="${RELEASE_ASSET_NAME}.tar.gz"
  tar cvfz "${COMPRESSION_NAME}" *
fi

${GRUPLOADER_COMMAND} -f ${COMPRESSION_NAME}

debug_log "${COMPRESSION_NAME}  Compressed file upload completed"