#!/bin/bash


TAG_VERSION="${TAG_VERSION:-$(git describe --tags --always)}"
BIN_NAME="${BIN_NAME:-$(basename $(pwd))}"
EXTRA_FILES="${EXTRA_FILES:-""}"
MAIN_GO="${MAIN_GO:-"main.go"}"
DIST_ROOT_PATH="dist"
SHA256_CHECKSUMS_FILE="${BIN_NAME}_${TAG_VERSION}_checksums.sha256"
MD5_CHECKSUMS_FILE="${BIN_NAME}_${TAG_VERSION}_checksums.md5"


function build() {
  local GOOS=${1:-$(go env GOHOSTOS)}
  local GOARCH=${2:-$(go env GOHOSTARCH)}
  local dist_tmp_path="${DIST_ROOT_PATH}/${BIN_NAME}_${GOOS}_${GOARCH}"

  # 判断是否为 Windows 系统
  if [ "$GOOS" == "windows" ]; then
    local output_bin_name="${BIN_NAME}.exe"
  else
    local output_bin_name="${BIN_NAME}"
  fi

  # 清理并创建目标目录
  rm -rf ${dist_tmp_path} && mkdir -p ${dist_tmp_path}

  # 构建命令
  local gbuild="GOOS=${GOOS} GOARCH=${GOARCH} go build -ldflags='-s -w -X main.TAG_version=${TAG_VERSION}' -o ${dist_tmp_path}/${output_bin_name} ${MAIN_GO}"
  echo "Building: $gbuild"
  eval $gbuild
  local compression_name="${BIN_NAME}_${GOOS}_${GOARCH}"

  if [ ! -z "${EXTRA_FILES}" ]; then
    cp -r ${EXTRA_FILES} ${dist_tmp_path}/
  fi

  # 打包目录
  if [ "$GOOS" == "windows" ]; then
    local compression_filename="${compression_name}.zip"
    # 如果是 Windows 系统，使用 zip 打包
    (cd ${dist_tmp_path} && zip -r "../${compression_filename}" *)
  else
    local compression_filename="${compression_name}.tar.gz"
    # 如果是其他系统，使用 tar 打包
    (cd ${dist_tmp_path} && tar -czf "../${compression_filename}" *)
  fi
  (cd dist && sha256sum ${compression_filename} >> ${SHA256_CHECKSUMS_FILE})
  (cd dist && md5sum ${compression_filename} >> ${MD5_CHECKSUMS_FILE})
  echo "Packaged: ${DIST_ROOT_PATH}/${compression_filename}"
}

# 构建并打包
build windows amd64
build windows arm64
build linux amd64
build linux arm64
build darwin amd64
build darwin arm64

for file in $(find ${DIST_ROOT_PATH} -type f -maxdepth 1); do
   ${GRUPLOADER_COMMAND} -f "$file"
done