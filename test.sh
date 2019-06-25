#!/bin/bash

set -euo pipefail

validate_terraform_config() {
  for dirname in "$@"; do
    terraform init -backend=false "${dirname}"
    terraform validate "${dirname}"
    echo "${dirname}: ✓"
  done
}

validate_terraform_config accounts dns production staging
