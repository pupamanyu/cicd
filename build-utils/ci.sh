#!/usr/bin/env bash

echo $(pwd)
chmod +x load_var.sh
chmod +x check_source_file.sh

echo "$(pwd)"

# Get a list of the current files in package form by querying Bazel.
files=()

for file in $(git show --pretty='format:' --name-only $commit_sha);do
#for file in */;do
    echo "hello inside"
    echo "bazel query ${file}"
    files+=($(bazel query $file))
    echo "files:  ${files}"

done

# Query for the associated buildables
buildables=$(bazel query \
    --keep_going \
    --noshow_progress \
    "kind(.*_binary, rdeps(//..., set(${files[*]})))")
echo "buildables ... $buildables"
# Run the tests if there were results
if [[ ! -z $buildables ]]; then
    echo "Load variables"
    ./load_var.sh

    echo "check source code type"
    code_type=$(./check_source_file.sh "$buildables")
    echo $code_type

    if [ "$code_type" == "python" ]; then
        echo "Building par file: $buildables".par
        buildable="$buildables"
        bazel build $buildable
    fi

    if [ "$code_type" == "java" ]; then
        echo "Building jar file: $buildables".jar
        buildable="$buildables"_deploy.jar
        bazel build $buildable
        echo ${pwd}
    fi

fi

#tests=$(bazel query \
#    --keep_going \
#    --noshow_progress \
#    "kind(test, rdeps(//..., set(${files[*]}))) except attr('tags', 'manual', //...)")
# Run the tests if there were results
#if [[ ! -z $tests ]]; then
#  echo "Running tests"
#  bazel test $tests
#fi
