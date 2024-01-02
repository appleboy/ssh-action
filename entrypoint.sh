#!/bin/sh

set -eu
set -o pipefail

export GITHUB="true"

{
    sh -c "/bin/drone-ssh $*"
} | tee /tmp/outFile

stdout=$(cat /tmp/outFile)
echo "stdout=${stdout//$'\n'/\\n}" >> $GITHUB_OUTPUT
