#!/bin/sh

set -eu

export GITHUB="true"

sh -c "/bin/drone-ssh $*"
