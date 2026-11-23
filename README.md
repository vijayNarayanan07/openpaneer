# Azure infrastructure with OpenTofu

Creates, per environment (dev, test), in Central India:
- Azure Database for PostgreSQL Flexible Server
- Azure Container Registry (ACR)
- 1 frontend App Service (Linux, Docker)
- 1+ gateway App Services (Linux, Docker), one plan each

Region, SKU, worker count, image and gateway count are controlled only through `infra/envs/<env>.tfvars`.

## Layout
```
infra/
  versions.tf backend.tf variables.tf main.tf outputs.tf
  envs/        dev.tfvars test.tfvars dev.backend.hcl test.backend.hcl
  modules/     registry postgres web_app
.github/workflows/infra.yml     infra pipeline (OpenTofu)
app-templates/                  deploy.yml, Dockerfile, docker-compose.local.yml for app repos
scripts/                        validate.sh, bootstrap-state.sh, check-azure-readiness.sh
```

## One environment = one tfvars + one state key
`envs/dev.tfvars` + `envs/dev.backend.hcl` (key `dev.tfstate`). Test uses its own pair, so the two never touch each other.

## Offline check (no Azure needed)
```bash
./scripts/validate.sh     # init -backend=false, fmt -check, validate
```

## Run against Azure
```bash
az login
export ARM_SUBSCRIPTION_ID=<id>
export ARM_ACCESS_KEY=<state storage key>
cd infra
tofu init -backend-config=envs/dev.backend.hcl
tofu plan  -var-file=envs/dev.tfvars -out=plan
tofu apply plan
```
Switch environment: `tofu init -reconfigure -backend-config=envs/test.backend.hcl`.

## Common changes
- **Add a gateway:** add an entry under `gateways` in the tfvars, then plan/apply.
- **Resize / move region:** edit `sku_name`, `worker_count` or `location` in the tfvars.
- **Add an environment:** copy `dev.tfvars` and `dev.backend.hcl`, change the names and key, add a GitHub Environment.
- **Non-secret app setting:** add to `app_settings` in the tfvars.
- **Secret app setting:** add to the GitHub environment secret `GATEWAY_SECRETS_JSON` / `FRONTEND_SECRETS_JSON` (JSON object).

## Pipelines
| Pipeline | Where | Trigger | Does |
|---|---|---|---|
| infra | this repo | PR on `infra/**` | fmt, validate, plan |
| infra | this repo | push to main | apply to dev |
| infra | this repo | manual (env=test) | apply to test, after reviewer approval |
| deploy | each app repo (`app-templates/deploy.yml`) | push to main | build, push (tag = commit SHA), deploy to dev |
| deploy | each app repo | manual | deploy to test, after approval |

OpenTofu ignores the image tag (`ignore_changes` in `modules/web_app`) so infra runs never revert what the app pipeline deployed. Do not remove it.

## GitHub secrets and variables
| Name | Type | Scope | Source |
|---|---|---|---|
| ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID | secret | repo | service principal from Azure admin |
| ARM_ACCESS_KEY | secret | repo | `scripts/bootstrap-state.sh` output |
| GATEWAY_SECRETS_JSON, FRONTEND_SECRETS_JSON | secret | environment | your app secrets, e.g. `{"API_KEY":"..."}` |
| ACR_USERNAME, ACR_PASSWORD | secret | app repo, per env | `tofu output acr_admin_username` / `acr_admin_password` |
| ACR_LOGIN_SERVER, WEBAPP_NAME | variable | app repo, per env | `tofu output` |

Create GitHub Environments `dev` (no rules) and `test` (required reviewers).

## Rotating credentials
- **DB password:** `tofu apply -replace=module.postgres.random_password.admin -var-file=envs/<env>.tfvars` (apps get the new `DATABASE_URL` on apply).
- **ACR password:** regenerate with `az acr credential renew`, then update `ACR_PASSWORD` and re-run `tofu apply` so app config refreshes.

## Teardown
`tofu destroy -var-file=envs/dev.tfvars`

## Temporary compromises (Contributor-only access)
| Now | Replace with | Needs |
|---|---|---|
| ACR admin credentials | Managed identity + AcrPull | Role assignment rights |
| Service principal secret in GitHub | GitHub OIDC | Admin creates federated credential |
| Storage account key for state | Entra auth + Blob Data role | Role assignment rights |
| Public Postgres + AllowAzureServices | VNet, delegated subnet, private DNS | Contributor is enough |
| GitHub secrets for app secrets | Key Vault | Role assignment rights |

State contains the DB and ACR passwords: keep the state storage account locked down.

## When Azure access arrives (checklist)
- [ ] Get service principal (client id, secret, tenant) from admin
- [ ] `./scripts/check-azure-readiness.sh` (providers, Postgres SKUs, B1 quota)
- [ ] `./scripts/bootstrap-state.sh`, then update `envs/*.backend.hcl`
- [ ] Set `project` in the tfvars
- [ ] `tofu init`, `plan`, `apply` locally for dev
- [ ] Push a first image manually and verify frontend, gateway and DB
- [ ] Add GitHub secrets/environments, enable `infra.yml`
- [ ] Add `deploy.yml` to app repos, confirm `tofu plan` shows no drift after a deploy
- [ ] Apply test (manual, approved)
