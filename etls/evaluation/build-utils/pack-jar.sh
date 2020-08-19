#!/bin/bash

cd /Users/ext.gampapathini/Documents/cicd/etls

# Manifest related variables
NAME="etls/evaluation"
SPECTITLE="Game Event End to End ETL"
SPECVERSION="$(git rev-parse --abbrev-ref HEAD)"
SPECVENDOR="Example Company, Inc."
IMPLTITLE="etls.evaluation"
IMPLVERSION="$(git rev-parse HEAD)"
IMPLVENDOR="Example Company, Inc."

# Artifact related variables
ARTIFACTSRCSIR="/Users/ext.gampapathini/Documents/cicd/etls/evaluation/game-1/game_event"
ARTIFACTJARNAME="${IMPLVERSION}_${SPECVERSION}.jar"

BAZELBINDIR="/Users/ext.gampapathini/Documents/cicd/bazel-bin/${NAME}"

gen_manifest() {
    echo -e "Name: ${NAME} \nSpecification-Title: ${SPECTITLE}\nSpecification-Version: ${SPECVERSION}\nSpecification-Vendor: ${SPECVENDOR}\nImplementation-Title: ${IMPLTITLE}\nImplementation-Version: ${IMPLVERSION}\nImplementation-Vendor: ${IMPLVENDOR}\n"
}

#TODO-  get bazel-bin directory  "bazel info bazel-bin"
get_bazel_bin_dir() {
    echo "bazel info bazel-bin"
}

pack_jar() {
  local MANIFESTTXT=${BAZELBINDIR}/manifest.txt
  cd ${BAZELBINDIR}
  gen_manifest > ${MANIFESTTXT} 2> /dev/null \
  && jar cmf ${MANIFESTTXT} ${ARTIFACTJARNAME} ${ARTIFACTSRCSIR} \
  && echo "Artifact packed into a JAR successfully"
}

pack_jar