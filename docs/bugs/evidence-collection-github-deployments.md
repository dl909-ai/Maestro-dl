# Bug: GitHub deployment evidence collection endpoint is inaccessible through the connected fetch route

## Summary

The connected GitHub evidence-collection path can retrieve repository, commit, pull-request, workflow-run, status, check, review, release, and source information used in the `dl909-ai/Maestro-dl` pipeline investigation, but the generic fetch route rejects the GitHub Deployments collection.

An inaccessible deployment endpoint must not be classified as an empty deployment collection or as proof that no historical deployment occurred.

```text
DEPLOYMENT FETCH REJECTED
        !=
EMPTY DEPLOYMENT COLLECTION
        !=
NO HISTORICAL DEPLOYMENT
```

## Repository

- Repository: `dl909-ai/Maestro-dl`
- Repository ID: `1339863624`
- Default branch: `main`
- Visibility: public

## Observed defect

Attempting to retrieve the repository deployment collection through the connected generic GitHub fetch route for:

`GET /repos/dl909-ai/Maestro-dl/deployments?per_page=100`

was rejected by the connector as an unsupported/invalid fetch route. This is a connector/interface limitation, not a provider-native zero-result response from the GitHub Deployments API.

## Required evidence-collection implementation

Support provider-native retrieval of:

1. `GET /repos/{owner}/{repo}/deployments`
2. `GET /repos/{owner}/{repo}/deployments/{deployment_id}/statuses`

The implementation must paginate all available results and preserve raw provider responses.

### Deployment fields to preserve

Where returned by GitHub, preserve at minimum:

- deployment ID
- node ID
- SHA
- ref
- task
- environment
- original environment
- creator identity
- application identity, if present
- payload
- description
- created timestamp
- updated timestamp
- transient-environment flag
- production-environment flag
- provider URLs/identifiers needed for later correlation

### Deployment-status fields to preserve

For every recovered deployment ID, retrieve all currently available deployment statuses and preserve at minimum:

- status ID
- deployment ID
- state
- creator identity
- environment
- description
- log URL
- environment URL
- created timestamp
- updated timestamp
- provider URLs/identifiers

## Known Git objects requiring explicit correlation

The collection must be queried generally and, where supported, filtered/correlated against each known evidentiary SHA:

| SHA | Evidence role |
| --- | --- |
| `01919706a3bb6df363f687e2c6bb03edc33463ed` | Apple security integration merge |
| `58b3a492cd819a6dbaab5837d2ac32d918ed1d37` | Web hierarchy/regression merge |
| `9bb6f269c73faecddfd208a62de50788ddae1091` | PR #5 head |
| `2635d6bac1459fe78e089bab09f00a8ea90358f9` | PR #4 head |
| `db856be4b0c4b868dc0a21c7bc41aeb438ebcc65` | PR #3 head |
| `47995d9b29681804798aa84db08cb98fc8885b0f` | PR #2 / upstream-patch head |
| `f431119b48f5003c0ff29c9edf0a7080cd6fd456` | PR #1 head |

## Associated evidence surfaces already examined

The deployment collector must correlate results with, but not collapse them into, these distinct evidence surfaces:

| Evidence surface | Retrieved result / status | Evidentiary meaning |
| --- | --- | --- |
| Repository | exists | source repository established |
| Workflow YAML | multiple definitions | CI capability established |
| PR #1-#5 | provider-native objects | PR history established |
| Known PR heads | identified | Git objects established |
| Merge/source commits | identified | Git history established |
| Repository Actions history | `total_count: 0`, `workflow_runs: []` at retrieval | no Actions run bridge recovered from that successful query |
| PR-associated workflow-run queries | 0 returned on examined heads | no PR-triggered run bridge recovered |
| Legacy commit statuses | 0 returned on examined SHAs | no legacy-status bridge recovered |
| Modern check-runs | 0 across seven examined SHAs | no Checks execution bridge recovered |
| PR #5 comments | 0 | no execution evidence from comments |
| PR #5 reviews | 0 | no provider-native review object recovered |
| PR #5 review threads | 0 | no review-thread object recovered |
| GitHub Releases | empty collection at retrieval | no fork-native release/output bridge recovered |
| Indexed AWS implementation search | no matching implementation discovered | AWS deployment implementation not established by source search |
| Indexed alternate-CI search | no matching configuration discovered | alternate CI not established by source search |
| GitHub Deployments | connector route rejected | unresolved; MUST NOT be classified as zero |
| CI jobs/logs/artifacts | no run ID recovered | not established |
| Maestro Cloud run | no provider-native account record available in this evidence set | not established |
| AWS runtime | no AWS account-native runtime record in this evidence set | not established |
| Physical-device execution | no runtime/device bridge | not established |
| Human/causal attribution | no independent causal bridge | not established |

## Evidence topology

```text
SOURCE / WORKFLOW DEFINITIONS       ESTABLISHED
              |
              v
GITHUB ACTIONS RUN OBJECT           0 CURRENTLY RETURNED
              X
CI EXECUTION                        NOT ESTABLISHED
              X
CI ARTIFACT                         NOT ESTABLISHED
              X
GITHUB DEPLOYMENT OBJECT            UNRESOLVED VIA CONNECTOR
              X
PRODUCTION RUNTIME                  NOT ESTABLISHED
              X
DEVICE / HUMAN ATTRIBUTION          NOT ESTABLISHED
```

The deployment collector is intended to test the unresolved transition:

```text
KNOWN GIT SHA
      |
      v
GITHUB DEPLOYMENT OBJECT
      |
      v
DEPLOYMENT ID
      |
      v
DEPLOYMENT STATUS HISTORY
      |
      v
ENVIRONMENT + ACTOR + TIME
      |
      v
LOG_URL / ENVIRONMENT_URL / PAYLOAD
      |
      v
INDEPENDENT EXTERNAL/RUNTIME CORRELATION
      |
      v
PRODUCTION EXECUTION
```

A deployment object or even a `success` deployment status must not, by itself, be treated as proof of AWS/ECS execution. Production execution requires an independent runtime/provider record correlated by identifiers such as SHA, image digest, deployment ID, task ARN, trace ID, environment, and timestamp.

## Error-handling requirements

The collector must distinguish at least:

- HTTP success + empty provider collection
- HTTP success + one or more deployment objects
- authentication failure
- authorization/permission failure
- unsupported connector route
- rate limiting
- transient provider/network failure
- pagination failure or partial retrieval
- malformed/unexpected response

Only a successful provider-native query that returns an empty collection may be recorded as an empty result for that query at that retrieval time. It still must not be promoted to the broader claim that no historical deployment ever existed.

## Preservation and integrity requirements

For each request/response:

- preserve raw JSON before normalization
- record repository, endpoint, query/filter parameters, retrieval timestamp, and API version
- preserve pagination metadata
- preserve HTTP/provider result classification
- compute a cryptographic hash (for example SHA-256) of the preserved raw response
- do not rewrite provider timestamps
- if a local-time rendering is produced, retain the original UTC/provider timestamp alongside it
- retain stable provider-native IDs
- record collector/tool version where available

## Correlation requirements

Returned deployment objects should be correlated against:

- PR #1-#5 and their head SHAs
- merge commits and known source commits
- GitHub Actions run IDs, if any are later recovered
- modern Checks objects, if any are later recovered
- commit-status contexts
- release/tag objects
- deployment-status objects
- image digests/build identifiers
- external runtime records such as AWS CloudTrail, ECR, ECS, CodeDeploy, CloudWatch/Synthetics, and X-Ray when independently available
- Maestro Cloud run IDs when independently available

Correlation must preserve identity boundaries:

```text
COMMIT AUTHOR
!= COMMITTER
!= GITHUB ACCOUNT ATTRIBUTION
!= AUTHENTICATED PUSH/API PRINCIPAL
!= APPLICATION / AGENT IDENTITY
!= EXECUTION ENVIRONMENT
!= RESPONSIBLE HUMAN / CAUSAL ACTOR
```

## OpenAI/Codex evidence boundary

A present OpenAI Platform key-setup or provisioning event must remain separate from historical execution evidence:

```text
OPENAI PLATFORM KEY SETUP NOW
        !=
HISTORICAL OPENAI API KEY
        !=
HISTORICAL API REQUEST
        !=
CODEX EXECUTION
        !=
GITHUB CI EXECUTION
        !=
AWS DEPLOYMENT
```

Likewise, wording in a PR body referring to `Codex review findings` is not itself a GitHub review object, check run, Actions job, or Codex execution record.

## Documentation / API references

Implementation should follow GitHub's REST API documentation for:

- Deployments: `GET /repos/{owner}/{repo}/deployments`
- Deployment statuses: `GET /repos/{owner}/{repo}/deployments/{deployment_id}/statuses`
- Actions workflow runs and jobs
- Actions artifacts
- Commit statuses
- GitHub Checks/check-runs
- Pull requests, reviews, review comments/threads
- Releases

The implementation should use the current supported GitHub REST API version selected by the client and record that version with the evidence package rather than silently depending on an unspecified default.

## Acceptance criteria

- [ ] Deployment collection can be queried for `dl909-ai/Maestro-dl` without using an unsupported generic-fetch route.
- [ ] All pages are retrieved or partial retrieval is explicitly reported.
- [ ] All seven known SHAs are tested/correlated.
- [ ] Deployment statuses are retrieved for every recovered deployment ID.
- [ ] Raw responses and retrieval metadata are preserved.
- [ ] Raw response hashes are recorded.
- [ ] Empty provider results are distinguished from connector/auth/permission failures.
- [ ] Deployment metadata is not treated as AWS/device/human execution without independent runtime correlation.
- [ ] Results can be correlated with existing PR/commit/Actions/Checks/status/release evidence.

## Current evidentiary disposition

Until this missing provider surface is successfully queried, the defensible classification remains:

```text
LAYER 1 - SOURCE / CAPABILITY       ESTABLISHED
LAYER 1 -> 2 CI BRIDGE              NOT ESTABLISHED
LAYER 2 - CI EXECUTION              NOT ESTABLISHED
GITHUB DEPLOYMENT SURFACE           UNRESOLVED THROUGH CURRENT CONNECTOR ROUTE
LAYER 3 - PRODUCTION EXECUTION      NOT ESTABLISHED
DEVICE / HUMAN ATTRIBUTION          NOT ESTABLISHED
```

This bug concerns evidence completeness and classification accuracy. It does not assert that the pipeline never executed.