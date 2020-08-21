#!/usr/bin/env bash
#
#Todo : remove hardcoded path
#cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
cd /workspace/cicd/
(
echo "Workspace directory: ${PWD}"

echo "commit sha is $(git rev-parse HEAD)"
echo "bazel  info is $(bazel info bazel-bin)"

echo "before path WORKSPACE ... ${WORKSPACE}"
echo "path is ... $(pwd)"
echo "before path is ... ${BASH_SOURCE[0]}"
DIRECTORY=`dirname $0`
echo "Direcory is .. $DIRECTORY"
echo "path is ... $(pwd)"

for file in "${PWD}/"*
do
  echo "file is ${file}"
done
) >> output.txt
$(gsutil cp output.txt gs://test_cicd_scripts/)
