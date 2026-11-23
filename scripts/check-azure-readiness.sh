#!/usr/bin/env bash
# Run once Azure access is granted (Phase 0 checks).
set -euo pipefail
for ns in Microsoft.Web Microsoft.DBforPostgreSQL Microsoft.ContainerRegistry Microsoft.Storage; do
  az provider register -n "$ns" >/dev/null
  echo "$ns: $(az provider show -n "$ns" --query registrationState -o tsv)"
done
echo "--- Postgres burstable SKUs in centralindia ---"
az postgres flexible-server list-skus -l centralindia --query "[?contains(name,'B_Standard')].name" -o tsv || true
echo "--- App Service quota: try creating a B1 plan or check Portal > Quotas ---"
