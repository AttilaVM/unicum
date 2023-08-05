#!/bin/bash
set -euo pipefail

table=${1:? "target iptables talbe such as filter"}
chain=${2:? "chain such"}
rule=${3:? "rule"}

if ! iptables -t "$table" --check "$chain" $rule > /dev/null 2>&1; then
    iptables -t "$table" --append "$chain" $rule
    echo "changed"
else
    echo "unchanged"
fi