#!/bin/bash
#
# Copyright 2020 Google LLC.
#
# This software is provided as-is, without warranty or representation
# for any use or purpose. Your use of it is subject to your agreement with Google.


n=0
until [[ $n -ge $4 ]]
do
  status=0
  gcloud composer environments run "${1}" --location "${2}" list_dags \
  2>&1 | grep "${3}" && break
  status=$?
  n=$(($n+1))
  sleep "${5}"
done
exit $status
