#!/usr/bin/env bash
#
# Manifest related variables
NAME="etls/evaluation"
SPECTITLE="Game Event End to End ETL"
SPECVERSION="$(echo some-feature-branch)"
SPECVENDOR="Example Company, Inc."
IMPLTITLE="etls.evaluation"
IMPLVERSION="$(echo git-commit-sha)"
IMPLVENDOR="Example Company, Inc."

# Artifact related variables
ARTIFACTBASEDIR="."
ARTIFACTDIR="."
ARTIFACTJARNAME="$(whoami).jar"

gen_manifest() {
    echo -e "Name: ${NAME} \nSpecification-Title: ${SPECTITLE}\nSpecification-Version: ${SPECVERSION}\nSpecification-Vendor: ${SPECVENDOR}\nImplementation-Title: ${IMPLTITLE}\nImplementation-Version: ${IMPLVERSION}\nImplementation-Vendor: ${IMPLVENDOR}\n"    
}

pack_jar() {
    local MANIFESTTXT=./manifest.txt
    gen_manifest > ${MANIFESTTXT} 2> /dev/null \
    && jar cmf ${MANIFESTTXT} ${ARTIFACTJARNAME} -C ${ARTIFACTBASEDIR} ${ARTIFACTDIR} \
    && echo "Artifact packed into a JAR successfully"
}

pack_jar
