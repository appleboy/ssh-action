#!/bin/sh

set -eu
set -o pipefail

export GITHUB="true"

{
    sh -c "/bin/drone-ssh $*"
} | tee /tmp/outFile

echo "stdout<<EOF" >> $GITHUB_OUTPUT
cat /tmp/outFile >> $GITHUB_OUTPUT
echo "EOF" >> $GITHUB_OUTPUT
