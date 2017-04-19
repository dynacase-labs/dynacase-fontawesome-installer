#!/usr/bin/env bash

if (( $# < 2 )); then
    usage
fi

SRC_DIR=$1
PACKAGE_NAME=$2
PACKAGE_VERSION=$3
UPLOAD_URL=distrib@ftp.anakeen.com:/share/ftp/third-party/

JSON_CMD=""

usage () {
    echo <<USAGE
update.sh source_dir package_name [package_version]

with:
- source_dir: the path to the dir where module sources can be found
- package_name: the name of the package on npm
- package_version: the version to use (defaults to latest)
USAGE

}

confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure?} [y/N]" response
    case $response in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

infirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure?} [Y/n]" response
    case $response in
        [nN][oO]|[nN])
            false
            ;;
        *)
            true
            ;;
    esac
}

get_npm_package_cmd () {
    local CMD
    local errors=0

    CMD=$(npm_config_parseable=1 npm ls -g "${1}" 2>/dev/null)
    if [ "$?" -gt "0" ]; then
        CMD=$(npm_config_parseable=1 npm ls "${1}" 2>/dev/null)
        if [ "$?" -gt "0" ]; then
            echo "${1} is not available, will install it locally through npm"
            npm install "${1}" 2> /dev/null
            if [ "$?" -gt "0" ]; then
                echo "an error occured during local installation of ${1}"
                errors=1
                else
                    CMD=$(npm_config_parseable=1 npm ls "${1}" 2>/dev/null)
                    echo "${1} has been sucessfully installed"
                fi
        fi
    fi

    if [ $errors -gt 0 ]; then
        return 1
    else
        _RETURN_="${CMD}"
        return 0
    fi
}

check_prereqs () {
    local errors=0
    # test git
    if ! hash git; then
        echo "git is not available"
        errors=1
    fi

    # test npm
    if ! hash npm; then
        echo "npm is not available"
        errors=1
    else
        # get json cmd
        get_npm_package_cmd json
        [ "$?" -eq "0" ] && JSON_CMD="${_RETURN_}/lib/json.js" || errors=1
    fi

    if [ $errors -gt 0 ]; then
        exit 1
    fi
}

get_npm_installed_package_version () {
    npm list --json "${1}" | "${JSON_CMD}" -D "#" "dependencies#${1}#version"
}

get_npm_latest_package_version() {
    npm info --json "${1}" | "${JSON_CMD}" version
}

main () {

    check_prereqs

    [ -z "${PACKAGE_VERSION}" ] && PACKAGE_VERSION=$(get_npm_latest_package_version "${PACKAGE_NAME}")
    local ZIP_FILE="${PACKAGE_NAME}-${PACKAGE_VERSION}.zip"
    local OLD_PACKAGE_VERSION=$(get_npm_installed_package_version ${PACKAGE_NAME})

    if [ "${OLD_PACKAGE_VERSION}" == "${PACKAGE_VERSION}" ]; then
        echo "package is aleady at version ${PACKAGE_VERSION}"
    else
        if [ "${OLD_PACKAGE_VERSION}" != "" ]; then
            echo "removing ${PACKAGE_NAME} (current version is ${OLD_PACKAGE_VERSION})"
            npm uninstall "${PACKAGE_NAME}"
        fi

        echo "installing ${PACKAGE_NAME}@${PACKAGE_VERSION}"
        npm install "${PACKAGE_NAME}@${PACKAGE_VERSION}"
    fi

    echo "removing old zip files"
    find ${SRC_DIR} -name "${PACKAGE_NAME}-*.zip" -exec GIT_DIR="${SRC_DIR}/.git" git rm --ignore-unmatch -rf {} \;

    echo "creating new zip file"
    (cd "${SRC_DIR}/node_modules" && zip -rqdgds 1m - "$PACKAGE_NAME/") > "${SRC_DIR}/${ZIP_FILE}"

    echo "updating VERSION file"
    echo "${PACKAGE_VERSION}" > "${SRC_DIR}/VERSION"

    echo "add VERSION file to git"
    GIT_DIR="${SRC_DIR}/.git" git add VERSION

    if confirm "add ${ZIP_FILE} to git ?"; then
        echo "add new zip file to git"
        GIT_DIR="${SRC_DIR}/.git" git add "${ZIP_FILE}"
    fi

    echo
    if confirm "Upload ${ZIP_FILE} to ${UPLOAD_URL} ?"; then
        echo
        echo "uploading new zip"
        scp "${SRC_DIR}/${ZIP_FILE}" "$UPLOAD_URL"
    fi

    echo
    if infirm "build webinst ?"; then
        echo
        make -C "${SRC_DIR}" webinst --quiet VERSION="${PACKAGE_VERSION}"
    fi

    # echo git status if something is staged
    GIT_DIR="${SRC_DIR}/.git" git status --porcelain | grep -qv '^ ' && GIT_DIR="${SRC_DIR}/.git" git status
}

main $@
