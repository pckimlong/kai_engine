# Releasing (Solo-friendly)

This repo is a monorepo. Releases are intentionally simple:
- You bump `version:` in the package you want to release.
- Automation opens a PR to update that package's `CHANGELOG.md`.
- After the changelog PR merges, automation tags the release.
- GitHub Actions publishes to pub.dev using Trusted Publishers (OIDC).

## Release steps (per package)

1. Update the package version:
   - `packages/<package>/pubspec.yaml` → bump `version:`
2. Merge to `main`.
3. Merge the auto-created changelog PR (if any).
4. The tag is created automatically, which triggers publishing.

## Notes

- pub.dev does not allow reusing or decreasing versions. If a publish fails, bump the version and try again.
- For `kai_engine_firebase_ai`, publish the matching `kai_engine` version first if you changed its dependency constraint.
