#!/usr/bin/env bash
#
#Todo : remove hardcoded path
cd /workspace/cicd/
# Manifest related variables
NAME="etls/evaluation/game-1"
SPECTITLE="Game Event End to End ETL"
SPECVERSION="$(git rev-parse --abbrev-ref HEAD)"
SPECVENDOR="Example Company, Inc."
IMPLTITLE="etls.evaluation"
IMPLVERSION="$(git rev-parse HEAD)"
IMPLVENDOR="Example Company, Inc."

# Artifact related variables
WORKSPACEDIR="$(git rev-parse --show-toplevel)"
ARTIFACTBASEDIR="${WORKSPACEDIR}/${NAME}"
BAZELBINDIR="${WORKSPACEDIR}/bazel-bin"
BAZELBINARTIFACTSDIR="${BAZELBINDIR}/etls/evaluation"

gen_manifest() {
  echo -e "Name: ${NAME} \nSpecification-Title: ${SPECTITLE}\nSpecification-Version: ${SPECVERSION}\nSpecification-Vendor: ${SPECVENDOR}\nImplementation-Title: ${IMPLTITLE}\nImplementation-Version: ${IMPLVERSION}\nImplementation-Vendor: ${IMPLVENDOR}\n"
}

pack_jar() {
  local DEBUG=1
  if [ ${DEBUG} -eq 1 ]; then
    echo "WORKSPACEDIR ... ${WORKSPACEDIR}"
    echo "MANIFESTTXT from outside.. ${MANIFESTTXT}"
    echo "ARTIFACTJARNAME .. ${ARTIFACTJARNAME}"
    echo "ARTIFACTBASEDIR .. ${ARTIFACTBASEDIR}"
    echo "ARTIFACTDIR .. ${ARTIFACTDIR}"
  fi

#  local TEMPDIR="$(mktemp --directory)"
#  local MANIFESTTXT="${TEMPDIR}/manifest.txt"
  cd /workspace/cicd/bazel-bin/etls/evaluation
  local MANIFESTTXT="/workspace/cicd/bazel-bin/etls/evaluation/manifest.txt"
  local ARTIFACTJARNAME="game-event_${IMPLVERSION}_${SPECVERSION}.jar"
  gen_manifest > ${MANIFESTTXT} 2> /dev/null \
  && jar cmf ${MANIFESTTXT} ${ARTIFACTJARNAME} -C ${ARTIFACTBASEDIR} * \
  && echo "Artifact packed into a JAR successfully"
}
pack_jar