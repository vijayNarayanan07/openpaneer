#!/usr/bin/env bash
# One-time: create the remote state storage. Requires `az login` and Contributor.
set -euo pipefail
LOCATION="${LOCATION:-centralindia}"
RG="rg-tfstate"
SA="${SA:-sttfstate$RANDOM}"

az group create -n "$RG" -l "$LOCATION"
az storage account create -n "$SA" -g "$RG" -l "$LOCATION" --sku Standard_LRS \
  --allow-blob-public-access false --min-tls-version TLS1_2
KEY=$(az storage account keys list -g "$RG" -n "$SA" --query "[0].value" -o tsv)
az storage container create -n tfstate --account-name "$SA" --account-key "$KEY"

echo
echo "Storage account: $SA"
echo "1. Put $SA in infra/envs/dev.backend.hcl and test.backend.hcl"
echo "2. Save this key as GitHub secret ARM_ACCESS_KEY (and export it locally):"
echo "   $KEY"
