#!/bin/sh

set -eu

export GITHUB="true"

{
    sh -c "/bin/drone-ssh $*"
} 2> /tmp/errFile | tee /tmp/outFile

stdout=$(cat /tmp/outFile)
stderr=$(cat /tmp/errFile)
echo "stdout=${stdout//$'\n'/\\n}" >> $GITHUB_OUTPUT
echo "stderr=${stderr//$'\n'/\\n}" >> $GITHUB_OUTPUT
