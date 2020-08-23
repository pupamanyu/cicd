#!/usr/bin/env bash
#
#Todo : remove hardcoded path
EXECPATH=$(pwd)
cd /workspace/cicd/
#cd /Users/ext.gampapathini/Documents/cicd
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
ARTIFACTDIR="game_event"
BAZELBINDIR="/tmp/bazel/output"
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


#  local TEMPDIR="$(mktemp -d)"
#  local MANIFESTTXT="${TEMPDIR}/manifest.txt"
#  local MANIFESTTXT="${BAZELBINARTIFACTSDIR}/manifest.txt"
#  cd /workspace/cicd/bazel-bin/etls/evaluation
#  cd /Users/ext.gampapathini/Documents/cicd/bazel-bin/etls/evaluation

#  local ARTIFACTJARNAME="${BAZELBINARTIFACTSDIR}/game-event_${IMPLVERSION}_${SPECVERSION}.jar"
#  local ARTIFACTJARNAME="game-event_${SPECVERSION}_${IMPLVERSION}.jar"
  echo "ARTIFACTJARNAME .. ${ARTIFACTJARNAME}"
  local ARTIFACTJARNAME="/game-event_${IMPLVERSION}_${SPECVERSION}.jar"
  cd ${EXECPATH}
  local MANIFESTTXT="./manifest.txt"

#  local MANIFESTTXT="./manifest.txt"
  gen_manifest > ${MANIFESTTXT} 2> /dev/null \
  && jar cmf ${MANIFESTTXT} ${ARTIFACTJARNAME} -C ${ARTIFACTBASEDIR} ${ARTIFACTDIR}
}
pack_jar