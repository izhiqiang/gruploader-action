#!/bin/bash -eux

INPUT_NODEVERSION="${INPUT_NODEVERSION:-"22"}"

ARCH=$(uname -m)
case $ARCH in
  x86_64) ARCH="x64" ;;
  aarch64) ARCH="arm64" ;;
  armv7l) ARCH="armv7l" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

TEMP="$(mktemp -d)"
trap 'rm -rf $TEMP' EXIT INT

# 基本 URL
NODE_BASE_URL="https://nodejs.org/dist"
if [[ ${INPUT_NODEVERSION} =~ ^[0-9]+$ ]]; then
  # 如果是主版本号，例如 23，获取该主版本的最后一个版本
  INPUT_NODEVERSION=$(curl -s ${NODE_BASE_URL}/ | grep -oP "v${INPUT_NODEVERSION}\.[0-9]+\.[0-9]+" | sort -V | tail -n 1 | sed 's/^v//')
elif [[ ${INPUT_NODEVERSION} =~ ^[0-9]+\.[0-9]+$ ]]; then
  # 如果是次版本号，例如 23.1，获取该次版本的最后一个版本
  INPUT_NODEVERSION=$(curl -s ${NODE_BASE_URL}/ | grep -oP "v${INPUT_NODEVERSION}\.[0-9]+" | sort -V | tail -n 1 | sed 's/^v//')
elif [[ ${INPUT_NODEVERSION} =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  # 如果是完整版本号，例如 32.1.0，直接使用输入的版本
  INPUT_NODEVERSION=${INPUT_NODEVERSION}
else
  # 否则，获取最新稳定版本（LTS 版本）
  INPUT_NODEVERSION=$(curl -s ${NODE_BASE_URL}/index.json | jq -r '.[] | select(.lts != false) | .version' | head -n 1 | sed 's/^v//')
fi

echo "Resolved Node.js version: $INPUT_NODEVERSION"
if [[ ${INPUT_NODEVERSION} == http* ]]; then
  NODE_TAR_URL=${INPUT_NODEVERSION}
else
  NODE_TAR_URL="$NODE_BASE_URL/v${INPUT_NODEVERSION}/node-v${INPUT_NODEVERSION}-linux-${ARCH}.tar.gz"
fi

mkdir -p /usr/local/node
wget --progress=dot:mega "${NODE_TAR_URL}" -O "${TEMP}/node.tar.gz"
(
    cd "${TEMP}" || exit 1
    tar -zxf node.tar.gz -C /usr/local/node --strip-components=1
)

export NODE_HOME=/usr/local/node
export PATH=${NODE_HOME}/bin:$PATH

node -v

npm -v
