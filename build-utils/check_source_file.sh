#!/usr/bin/env bash

function find_source_code_type()
{
    local py_source=".py"
    local java_source=".java"
    local source_code=""
    #buildables="//bigquery_pipeline:bigquery_github_trends"
    local __buildable=$1
    filename=${__buildable#*//}
    FILE=${filename%%:*}/BUILD
#    echo "Build file: $FILE"

    if [[ ! -z $(grep $py_source $FILE) ]]; then
        source_code="python"
    fi

    if [[ ! -z $(grep $java_source $FILE) ]]; then
        source_code="java"
    fi
    echo "$source_code"

}


source_code_type=$(find_source_code_type $1)
echo $source_code_type