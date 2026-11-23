#!/usr/bin/env bash
# Offline checks: no Azure login or state backend needed.
set -euo pipefail
cd "$(dirname "$0")/../infra"
tofu init -backend=false -input=false
tofu fmt -check -recursive
tofu validate
echo "OK: fmt + validate passed"
