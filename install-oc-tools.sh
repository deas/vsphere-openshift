#!/usr/bin/env bash
# from upstream
# https://github.com/cptmorgan-rh/install-oc-tools

set -e

OS=$(uname -s)

if [ "${OS}" == 'Linux' ]; then
  OS=linux
elif [ "${OS}" == 'Darwin' ]; then
  OS=mac
else
  echo "OS Unsupported: ${OS}"
  exit 99
fi

ARCH=$(uname -m)
MIRROR_DOMAIN='https://mirror.openshift.com'

if [ "${ARCH}" == 'x86_64' ]; then
  MIRROR_PATH='/pub/openshift-v4/x86_64/clients'
elif [ "${ARCH}" == 'arm64' ]; then
  MIRROR_PATH='/pub/openshift-v4/arm64/clients'
elif [ "${ARCH}" == 's390x' ]; then
  MIRROR_PATH='/pub/openshift-v4/s390x/clients'
elif [ "${ARCH}" == 'ppc64le' ]; then
  MIRROR_PATH='/pub/openshift-v4/ppc64le/clients'
else
  echo "Architecture Unsupported: ${ARCH}"
  exit 99
fi

: "${BIN_PATH:=$(pwd)/bin}"

run() {

  case "$1" in
    --latest)
      latest "$2"
      ;;
    --version)
      version "$2"
      ;;
    --info)
      version_info "$2"
      ;;
    --stable)
      stable "$2"
      ;;
    --cleanup)
      remove_old_ver
      ;;
    --help)
      show_help
      exit 0
      ;;
    *)
      show_help
      exit 0
  esac

}

check_internet(){

status_code=$(curl --write-out "%{http_code}" --silent --output /dev/null "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/stable/release.txt")

if [[ "$status_code" -ne 200 ]]; then
  echo "Internet Access is required for this tool to run."
  exit 1
fi

}

verify_version(){

status_code=$(curl --write-out "%{http_code}" --silent --output /dev/null "$1")

if [[ "$status_code" -ne 200 ]]; then
  echo "Version $2 does not exist"
  exit 1
fi

}

version_info(){

  status_code=$(curl --write-out "%{http_code}" --silent --output /dev/null "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/$1/release.txt")

  if [[ "$status_code" -ne 200 ]]; then
    echo "Version $1 does not exist"
    exit 1
  else
    releasetext="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/$1/release.txt"
    errata_url=$(curl --silent "${releasetext}" 2>/dev/null | grep url | sed -e 's/    url: //')
    k8s_ver=$(curl --silent "${releasetext}" 2>/dev/null | grep -m1 kubernetes | sed -e 's/  kubernetes //')
    upgrades=$(curl --silent "${releasetext}" 2>/dev/null | grep Upgrades | sed -e 's/  Upgrades: //')

    echo "$1 Version Info:"
    echo -e "\nKubernetes Version: $k8s_ver"
    echo -e "\n$1 can be upgraded from the following versions: $upgrades"
    echo -e "\nErrata: $errata_url"
    exit 0
  fi

}

version() {

  # restore_version "$1"

  if [[ "$1" == "" ]]; then
    echo "Please specify a version."
    echo "Example: install-oc-tools --version 4.4.10"
    exit 1
  fi

  status_code=$(curl --write-out "%{http_code}" --silent --output /dev/null "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/$1/release.txt")

  if [[ "$status_code" -ne 200 ]]; then
    echo "Version $1 does not exist"
    exit 1
  else
    VERSION=$(curl -s "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/$1/release.txt" | grep 'Name:' | awk '{ print $NF }')
    CUR_VERSION=$(oc version 2>/dev/null | grep Client | sed -e 's/Client Version: //')
    if [ "$VERSION" == "$CUR_VERSION" ]; then
      echo "${VERSION} already installed."
      exit 0
    fi
    CLIENT="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/$1/openshift-client-${OS}.tar.gz"
    INSTALL="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/$1/openshift-install-${OS}.tar.gz"
    download "$CLIENT" "$INSTALL"
  fi

}

latest() {
  restore_latest "$1"

  if [[ "$1" == "" ]]; then
    VERSION=$(curl -s "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/latest/release.txt" | grep 'Name:' | awk '{ print $NF }')
    CUR_VERSION=$(oc version 2>/dev/null | grep Client | sed -e 's/Client Version: //')
      if [ "$VERSION" == "$CUR_VERSION" ]; then
        echo "${VERSION} is installed."
        exit 0
      fi
    CLIENT="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/latest/openshift-client-${OS}.tar.gz"
    INSTALL="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/latest/openshift-install-${OS}.tar.gz"
    download "$CLIENT" "$INSTALL"
  else
    verify_version "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/latest-$1/release.txt" "$1"
    VERSION=$(curl -s "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/latest-$1/release.txt" | grep 'Name:' | awk '{ print $NF }')
    CUR_VERSION=$(oc version 2>/dev/null | grep Client | sed -e 's/Client Version: //')
    if [ "$VERSION" == "$CUR_VERSION" ]; then
      echo "${VERSION} already installed."
      exit 0
    fi
    CLIENT="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/latest-$1/openshift-client-${OS}.tar.gz"
    INSTALL="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/latest-$1/openshift-install-${OS}.tar.gz"
    download "$CLIENT" "$INSTALL"
  fi

}

candidate() {

  restore_candidate "$1"

  if [[ "$1" == "" ]]; then
    VERSION=$(curl -s "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/candidate/release.txt" | grep 'Name:' | awk '{ print $NF }')
    CUR_VERSION=$(oc version 2>/dev/null | grep Client | sed -e 's/Client Version: //')
      if [ "$VERSION" == "$CUR_VERSION" ]; then
        echo "${VERSION} is installed."
        exit 0
      fi
    CLIENT="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/candidate/openshift-client-${OS}.tar.gz"
    INSTALL="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/candidate/openshift-install-${OS}.tar.gz"
    download "$CLIENT" "$INSTALL"
  else
    verify_version "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/candidate-$1/release.txt" "$1"
    VERSION=$(curl -s "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/candidate-$1/release.txt" | grep 'Name:' | awk '{ print $NF }')
    CUR_VERSION=$(oc version 2>/dev/null | grep Client | sed -e 's/Client Version: //')
    if [ "$VERSION" == "$CUR_VERSION" ]; then
      echo "${VERSION} already installed."
      exit 0
    fi
    CLIENT="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/candidate-$1/openshift-client-${OS}.tar.gz"
    INSTALL="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/candidate-$1/openshift-install-${OS}.tar.gz"
    download "$CLIENT" "$INSTALL"
  fi

}

fast() {

  restore_fast "$1"

  if [[ "$1" == "" ]]; then
    VERSION=$(curl -s "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/fast/release.txt" | grep 'Name:' | awk '{ print $NF }')
    CUR_VERSION=$(oc version 2>/dev/null | grep Client | sed -e 's/Client Version: //')
      if [ "$VERSION" == "$CUR_VERSION" ]; then
        echo "${VERSION} is installed."
        exit 0
      fi
    CLIENT="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/fast/openshift-client-${OS}.tar.gz"
    INSTALL="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/fast/openshift-install-${OS}.tar.gz"
    download "$CLIENT" "$INSTALL"
  else
    verify_version "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/fast-$1/release.txt" "$1"
    VERSION=$(curl -s "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/fast-$1/release.txt" | grep 'Name:' | awk '{ print $NF }')
    CUR_VERSION=$(oc version 2>/dev/null | grep Client | sed -e 's/Client Version: //')
    if [ "$VERSION" == "$CUR_VERSION" ]; then
      echo "${VERSION} already installed."
      exit 0
    fi
    CLIENT="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/fast-$1/openshift-client-${OS}.tar.gz"
    INSTALL="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/fast-$1/openshift-install-${OS}.tar.gz"
    download "$CLIENT" "$INSTALL"
  fi

}

stable() {

  restore_stable "$1"

  if [[ "$1" == "" ]]; then
    VERSION=$(curl -s "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/stable/release.txt" | grep 'Name:' | awk '{ print $NF }')
    CUR_VERSION=$(oc version 2>/dev/null | grep Client | sed -e 's/Client Version: //')
      if [ "$VERSION" == "$CUR_VERSION" ]; then
        echo "${VERSION} is installed."
        exit 0
      fi
    CLIENT="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/stable/openshift-client-${OS}.tar.gz"
    INSTALL="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/stable/openshift-install-${OS}.tar.gz"
    download "$CLIENT" "$INSTALL"
  else
    verify_version "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/stable-$1/release.txt" "$1"
    VERSION=$(curl -s "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/stable-$1/release.txt" | grep 'Name:' | awk '{ print $NF }')
    CUR_VERSION=$(oc version 2>/dev/null | grep Client | sed -e 's/Client Version: //')
    if [ "$VERSION" == "$CUR_VERSION" ]; then
      echo "${VERSION} already installed."
      exit 0
    fi
    CLIENT="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/stable-$1/openshift-client-${OS}.tar.gz"
    INSTALL="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp/stable-$1/openshift-install-${OS}.tar.gz"
    download "$CLIENT" "$INSTALL"
  fi

}

nightly() {

  if [[ "$1" == "" ]]; then
    VERSION=$(curl -s "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp-dev-preview/latest/release.txt" | grep 'Name:' | awk '{ print $NF }')
    CUR_VERSION=$(oc version 2>/dev/null | grep Client | sed -e 's/Client Version: //')
      if [ "$VERSION" == "$CUR_VERSION" ]; then
        echo "${VERSION} is installed."
        exit 0
      fi
    CLIENT="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp-dev-preview/latest/openshift-client-${OS}.tar.gz"
    INSTALL="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp-dev-preview/latest/openshift-install-${OS}.tar.gz"
    download "$CLIENT" "$INSTALL"
  else
    verify_version "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp-dev-preview/latest-$1/release.txt" "$1"
    VERSION=$(curl -s "${MIRROR_DOMAIN}${MIRROR_PATH}/ocp-dev-preview/latest-$1/release.txt" | grep 'Name:' | awk '{ print $NF }')
    CUR_VERSION=$(oc version 2>/dev/null | grep Client | sed -e 's/Client Version: //')
    if [ "$VERSION" == "$CUR_VERSION" ]; then
      echo "$VERSION already installed."
      exit 0
    fi
    CLIENT="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp-dev-preview/latest-$1/openshift-client-${OS}.tar.gz"
    INSTALL="${MIRROR_DOMAIN}${MIRROR_PATH}/ocp-dev-preview/latest-$1/openshift-install-${OS}.tar.gz"
    download "$CLIENT" "$INSTALL"
  fi

}

extract() {

  mkdir -p ${BIN_PATH}
  echo -e "\nExtracting oc and kubectl from openshift-client-${OS}.tar.gz to ${BIN_PATH}"
  tar -zxf "/tmp/openshift-client-${OS}.tar.gz" -C ${BIN_PATH}
  echo -e "\nExtracting openshift-install from openshift-install-${OS}.tar.gz to ${BIN_PATH}"
  tar -zxf "/tmp/openshift-install-${OS}.tar.gz" -C ${BIN_PATH}

}

cleanup() {
  rm -rf ${BIN_PATH}/README.md
  rm -rf "/tmp/openshift-client-${OS}.tar.gz"
  rm -rf "/tmp/openshift-install-${OS}.tar.gz"

}

uninstall(){

	if ls ${BIN_PATH}/oc 1> /dev/null 2>&1 && ls ${BIN_PATH}/openshift-install 1> /dev/null 2>&1 && ls ${BIN_PATH}/kubectl 1> /dev/null 2>&1
  then
  read -rp "Delete the following files?
$(echo -e "\n")
$(for i in oc kubectl openshift-install; do ls -1 ${BIN_PATH}/$i 2>/dev/null; done)
$(for i in oc kubectl openshift-install; do ls -1 ${BIN_PATH}/$i*bak 2>/dev/null; done)
$(echo -e "\nY/N? ")"

  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    for i in oc kubectl openshift-install; do rm -f ${BIN_PATH}/$i*bak 2>/dev/null; done
    for i in oc kubectl openshift-install; do rm -f ${BIN_PATH}/$i 2>/dev/null; done
    exit 0
  elif [[ $REPLY =~ ^[Nn]$ ]]
  then
    exit 0
  else
    echo "Invalid response."
    exit 1
  fi
else
  echo "No versions found."
  exit 0
fi

}

show_ver() {

  if which oc &>/dev/null; then
      echo -e "\noc version: $(oc version 2>/dev/null | grep Client | sed -e 's/Client Version: //')"
  else
      echo "Error getting oc version. Please rerun script."
  fi

  if which kubectl &>/dev/null; then
      echo -e "\nkubectl version: $(kubectl version --client | grep -o "GitVersion:.*" | cut -d, -f1)"
  else
      echo "Error getting kubectl version. Please rerun script."
  fi

  if which openshift-install &>/dev/null; then
      echo -e "\nopenshift-install version: $(openshift-install version | grep openshift-install | sed -e 's/openshift-install //')"
  else
      echo "Error getting openshift-install version. Please rerun script."
  fi

}

download(){

echo -n "Downloading openshift-client-${OS}.tar.gz:    "
wget --progress=dot "$1" -O "/tmp/openshift-client-${OS}.tar.gz" 2>&1 | \
    grep --line-buffered "%" | \
    sed -e "s,\.,,g" | \
    awk '{printf("\b\b\b\b%4s", $2)}'
echo -ne "\b\b\b\b"
echo " Download Complete."

echo -n "Downloading openshift-install-${OS}.tar.gz:    "
wget --progress=dot "$2" -O "/tmp/openshift-install-${OS}.tar.gz" 2>&1 | \
    grep --line-buffered "%" | \
    sed -e "s,\.,,g" | \
    awk '{printf("\b\b\b\b%4s", $2)}'
echo -ne "\b\b\b\b"
echo " Download Complete."

}

show_help() {

    cat  << ENDHELP
USAGE: $(basename "$0")
install-oc-tools is a small script that will download the latest, stable, fast, nightly,
or specified version of the oc command line tools, kubectl, and openshift-install.

Options:
    --latest:  Installs the latest specified version. If no version is specified then it
               downloads the latest stable version of the oc tools.
      Example: install-oc-tools --latest 4.4
    --update:  Same as --latest
    --fast:    Installs the latest fast version. If no version is specified then it downloads
               the latest fast version.
      Example: install-oc-tools --fast 4.4
    --stable:  Installs the latest stable version. If no version is specified then it
               downloads the latest stable version of the oc tools.
      Example: install-oc-tools --stable 4.4
  --candidate: Installs the candidate version. If no version is specified then it
               downloads the latest candidate version of the oc tools.
      Example: install-oc-tools --candidate 4.4
    --version: Installs the specific version.  If no version is specified then it
               downloads the latest stable version of the oc tools.
      Example: install-oc-tools --version 4.4.10
    --info:    Displays Errata URL, Kubernetes Version, and versions it can be upgraded from.
      Example: install-oc-tools --info 4.4.10
    --nightly: Installs the latest nightly version. If you do not specify a version it will grab
               the latest version.
      Example: install-oc-tools --nightly
    --cleanup: This deleted all backed up version of oc, kubectl, and openshift-install
      Example: install-oc-tools --cleanup
  --uninstall: This will delete all copies of oc, kubectl, and openshift-install including backups
      Example: install-oc-tools --uninstall
    --help:    Shows this help message

You may override the binary path by setting it in BIN_PATH environment variable
- BIN_PATH: Where to save the oc tools. Default: $(pwd)/bin

ENDHELP

}

main() {

  check_internet
  run "$1" "$2"

  extract

  cleanup

  show_ver

}

main "$@"