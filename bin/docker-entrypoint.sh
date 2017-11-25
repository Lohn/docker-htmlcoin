#!/bin/bash
set -x

USER=htmlcoin

chown -R ${USER} .
exec gosu ${USER} "$@"
