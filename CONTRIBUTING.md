# Contributing to Kai Engine

Thank you for your interest in contributing to Kai Engine! We welcome contributions from the community and are excited to collaborate with you.

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md) to ensure a welcoming environment for everyone.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/kai_engine.git`
3. Create a new branch: `git checkout -b my-branch-name`
4. Make your changes
5. Commit your changes: `git commit -am 'Add some feature'`
6. Push to the branch: `git push origin my-branch-name`
7. Submit a pull request

## Development Setup

1. Install Flutter SDK
2. Navigate to the package you want to work on:
   ```bash
   cd packages/kai_engine
   # or
   cd packages/kai_engine_firebase_ai
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```

## Code Style

We follow the official Dart style guide. Please ensure your code adheres to these standards:

- Run `dart format .` to format your code
- Run `flutter analyze` to check for static analysis issues

## Testing

All changes should include appropriate tests:

- Unit tests for new functionality
- Widget tests for UI components
- Integration tests for complex interactions

Run tests with:
```bash
flutter test
```

For coverage reports:
```bash
flutter test --coverage
```

## Pull Request Process

1. Ensure any install or build dependencies are removed before the end of the layer when doing a build
2. Update the README.md with details of changes to the interface, this includes new environment variables, exposed ports, useful file locations and container parameters
3. Increase the version numbers in any examples files and the README.md to the new version that this Pull Request would represent. The versioning scheme we use is [SemVer](http://semver.org/)
4. Your pull request will be reviewed by maintainers, who may request changes
5. Once approved, your pull request will be merged

## Reporting Issues

If you find a bug or have a feature request, please [open an issue](https://github.com/pckimlong/kai_engine/issues/new) on GitHub. Please include:

1. A clear title and description
2. As much relevant information as possible
3. A code sample or executable test case demonstrating the expected behavior that is not occurring

## Publishing

Only maintainers can publish new versions. The publishing process is automated through GitHub Actions when a new version tag is pushed.

To release a new version:
1. Update the version in `pubspec.yaml`
2. Update the CHANGELOG.md
3. Create a new tag: `git tag v1.0.0`
4. Push the tag: `git push origin v1.0.0`

## Questions?

If you have any questions, feel free to [open a discussion](https://github.com/pckimlong/kai_engine/discussions) or contact the maintainers.