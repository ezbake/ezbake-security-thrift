#!/bin/bash

#   Copyright (C) 2013-2014 Computer Sciences Corporation
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

cwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ -z $REQUIRED_THRIFT_VERSION ] && REQUIRED_THRIFT_VERSION='0.9.1'
[ -z $BUILD_DIR ]               && BUILD_DIR='target/gen-thrift'


GENERATE_ARGS=("$@")
THRIFT_RESOURCE_DIR=${GENERATE_ARGS[0]}
THRIFT_INSTALLATION_PATH=${GENERATE_ARGS[1]:-/usr/local}
LANGUAGES_TO_GENERATE=(${GENERATE_ARGS[@]:2})

FINAL_DIR="src/main"
THRIFT_BINARY=${THRIFT_INSTALLATION_PATH}/bin/thrift
EZBAKE_BASE_THRIFT_DIR=${THRIFT_RESOURCE_DIR}/ezbake-base-thrift


fail() {
  echo $@
  exit 1
}


#check if languagues to generate have be specified
if [ ${#LANGUAGES_TO_GENERATE[*]} -eq 0 ]; then
    echo "*** Thrift Generate: No language to generate"
    exit 0
fi


# Test to see if we have thrift installed
VERSION=$(${THRIFT_BINARY} -version 2>/dev/null | grep -F "${REQUIRED_THRIFT_VERSION}" |  wc -l)
if [ "$VERSION" -ne 1 ] ; then
  # Nope: bail
  echo "****************************************************"
  echo "*** thrift is not available"
  echo "***   expecting 'thrift -version' to return ${REQUIRED_THRIFT_VERSION}"
  echo "*** generated code will not be updated"
  fail "****************************************************"
fi


#check if we're in a module path
if [ ! -d  "../src/main/scripts/" ]; then
    echo "Unable to generate thrift files"
    exit 0
fi

#check if ezbake base thrift files were pulled from dependency
if [ ! -d "${EZBAKE_BASE_THRIFT_DIR}" ]; then
    fail ">>>> Unable to access ezbake base thrift directory - ${EZBAKE_BASE_THRIFT_DIR}"
fi


THRIFT_ARGS=" -I src/main/thrift -I ../services/src/main/thrift -I ${EZBAKE_BASE_THRIFT_DIR}/src/main/thrift -o $BUILD_DIR"
mkdir -p $BUILD_DIR
rm -rf $BUILD_DIR/gen-java
rm -rf $BUILD_DIR/gen-cpp
rm -rf $BUILD_DIR/gen-py
rm -rf $BUILD_DIR/gen-rb
rm -rf $BUILD_DIR/gen-nodejs


#generate thrift source files
for f in ./src/main/thrift/*.thrift; do
  ${THRIFT_BINARY} ${THRIFT_ARGS} --gen java $f || fail unable to generate java thrift classes
  ${THRIFT_BINARY} ${THRIFT_ARGS} --gen py:new_style $f || fail unable to generate python thrift classes
  ${THRIFT_BINARY} ${THRIFT_ARGS} --gen rb $f || fail unable to generate ruby thrift classes
  ${THRIFT_BINARY} ${THRIFT_ARGS} --gen cpp:cob_style $f || fail unable to generate cpp thrift classes
  ${THRIFT_BINARY} ${THRIFT_ARGS} --gen js:node -r $f || fail unable to generate js:node thrift classes
done


#move generated files
for i in $(seq 0 $((${#LANGUAGES_TO_GENERATE[@]} - 1))); do

    if [[ "java" == "${LANGUAGES_TO_GENERATE[$i]}" ]]; then
        rm -rf "${FINAL_DIR}/java"
        cp -Rv  "${BUILD_DIR}/gen-java" "${FINAL_DIR}/java" || fail unable to copy java thrift classes 
    fi

    if [[ "python" == "${LANGUAGES_TO_GENERATE[$i]}" ]]; then
        rm -rf "${FINAL_DIR}/python"
        cp -Rfv  "${BUILD_DIR}/gen-py/." "${FINAL_DIR}/python/" || fail unable to copy python thrift classes

        "${cwd}/generate_setup.py" -p pom.xml -d "${FINAL_DIR}/python"
    fi

    if [[ "node" == "${LANGUAGES_TO_GENERATE[$i]}" ]]; then
        rm -rf "${FINAL_DIR}/node"
        cp -Rv  "${BUILD_DIR}/gen-nodejs" "${FINAL_DIR}/node" || fail unable to copy js:node thrift classes
    fi

    if [[ "cpp" == "${LANGUAGES_TO_GENERATE[$i]}" ]]; then
        DEST_DIR="${FINAL_DIR}/cpp"
        rm -rf ${DEST_DIR}
        mkdir -p "${DEST_DIR}/include"
        
        for f in `find ${BUILD_DIR}/gen-cpp -name "*.cpp"`; do
            filename=${f##*/}
            if test "${filename#*skeleton}" != "${filename}"; then
                #do not include generated thrift .skeleton. files
                continue
            fi

            cp -fv $f "${DEST_DIR}" || fail unable to copy cpp thrift classes
        done

        for f in `find ${BUILD_DIR}/gen-cpp -name "*.h"`; do
            filename=${f##*/}

            cp -fv $f "${DEST_DIR}/include" || fail unable to copy cpp thrift classes
        done
    fi
done

