# API contract

`v1.json` is a copy of the Tallyvel API's OpenAPI 3.1 document for `/api/v1`.
It is the contract the app is written against. Do not edit it by hand.

| | |
|---|---|
| API repo | https://github.com/ArchipeSesanga/TallyVel |
| Source file | `clients/typescript/openapi.json` (the API's committed snapshot of `/openapi/v1.json`) |
| Last API commit that changed that file | `944c74a0c16ec26be0c4bcb997952865aa751441` (2026-11-09, "Regenerate the API types and the TypeScript client for invites, proofs and the safe close") |
| API HEAD when copied | `014980ee70d9ac210800296a20de61364c409ec1` (branch `dev`) |
| SHA-256 of `v1.json` | `08ed639f93b9896a998ae0faf56a3daa0a4add5d1f1e552464dc3449320f8a0d` |

The API's working tree had no uncommitted change to the source file when it was
copied, so `v1.json` is byte-for-byte the file at `944c74a` and at HEAD.

This is the API's committed snapshot. It was not regenerated from a running API,
so it is only as fresh as that snapshot.

## Updating

Regenerate the snapshot in the API repo (see its README), then copy the file
here and update the commit hashes and checksum in the table above:

```
cp <api-repo>/clients/typescript/openapi.json contract/v1.json
shasum -a 256 contract/v1.json
```
