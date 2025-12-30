# Publishing to pub.dev (Automated)

This repo uses pub.dev **Trusted Publishers** (OIDC) for automated publishing, following the official guide:
`https://dart.dev/tools/pub/automated-publishing`.

## One-time setup (per package)

1. Create/claim the package on pub.dev (first publish can be manual).
2. On pub.dev, open the package **Admin** page and configure a **Trusted Publisher**:
   - GitHub repository: `pckimlong/kai_engine`
   - Workflow file: `.github/workflows/pub-publish.yml`
3. Ensure GitHub Actions has workflow permissions enabled for OIDC.

## How publishing is triggered

Publishing runs on git tags you create:
- `kai_engine-v*` → publishes `packages/kai_engine`
- `kai_engine_firebase_ai-v*` → publishes `packages/kai_engine_firebase_ai`
- `kai_engine_chat_ui-v*` → publishes `packages/kai_engine_chat_ui`
- `prompt_block-v*` → publishes `packages/prompt_block`

Workflow: `.github/workflows/pub-publish.yml`

## Recommended solo-maintainer flow

1. Make changes in a PR (or directly on a branch).
2. When you're ready to release a package, update only `version:` in that package's `pubspec.yaml`.
3. Merge to `main`.
4. Automation will open a PR to update `CHANGELOG.md`, then create the release tag after it merges, triggering publish.

If the changelog PR cannot be created due to GitHub Actions policy, create a fine-grained PAT with `Contents: Read and write` + `Pull requests: Read and write` and add it as repository secret `CHANGELOG_PR_TOKEN`.

## Manual publish (first time / troubleshooting)

From the package folder:
- Dart packages: `dart pub publish --dry-run` then `dart pub publish`
- Flutter packages: `flutter pub publish --dry-run` then `flutter pub publish`
