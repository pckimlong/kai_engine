# Changelog

## [2.0.0](https://github.com/pckimlong/kai_engine/compare/kai_engine_firebase_ai-v1.0.0...kai_engine_firebase_ai-v2.0.0) (2025-12-30)


### ⚠ BREAKING CHANGES

* **kai_engine:** GenerationServiceBase and implementations now return GenerationResult instead of String. GenerationResult.requestMessage is replaced by requestMessages.
* **kai_engine:** addMessages now returns Future<IList<CoreMessage>> (was Future<void>). Generation invocations are no longer serialized.
* **kai_engine:** CoreMessage now requires a timestamp. Call sites must provide it or use factory constructors that auto-populate it.
* **api:** ParallelContextBuilder.build now requires (QueryContext input, IList<CoreMessage> context) PostResponseEngine.process now requires a QueryContext input parameter CoreMessageFirebaseExtension.generationUsage now returns Map<String, dynamic>? instead of GenerationUsage?

### Features

* **api:** enrich builder and post engine params ([6595083](https://github.com/pckimlong/kai_engine/commit/6595083e66f6d28d14109b75c0aed3fd64d420d5))
* **ci:** add Melos-based automatic release workflow ([ad4acd3](https://github.com/pckimlong/kai_engine/commit/ad4acd38daef7132bb11344cfa5d53168d43ad61))
* **inspector:** add edit and generate screen with message bubbles for playground ([799ac03](https://github.com/pckimlong/kai_engine/commit/799ac0371c855e9aa7bc3b54a83e8a24b7098d91))
* **inspector:** add prompt and generated messages logging with UI debugging ([3f78bb1](https://github.com/pckimlong/kai_engine/commit/3f78bb133f97d07213baf3213171d88f15f8d7f0))
* **inspector:** enhance system with AI response tracking and mobile-responsive UI ([6bc4639](https://github.com/pckimlong/kai_engine/commit/6bc4639a3133f1a11862858e7b3ab96b821005e5))
* **kai_engine:** add input message ID to context builder interfaces and update related implementations ([3ec30e1](https://github.com/pckimlong/kai_engine/commit/3ec30e1efbfb64724881598c4d4a9a96797103dd))
* **kai_engine:** add tooling method with function call support ([0ccd71b](https://github.com/pckimlong/kai_engine/commit/0ccd71b5137218034163c6b89373e3dd629d0685))
* **kai_engine:** require timestamp on CoreMessage and persist it ([7d3b034](https://github.com/pckimlong/kai_engine/commit/7d3b03439232200e4db27358f1f842693fb2ce05))
* **kai_engine:** update GenerationResult model and service interfaces ([f5eb7a7](https://github.com/pckimlong/kai_engine/commit/f5eb7a701eb645ae623cb3f18cfcb7947950ecc6))


### Bug Fixes

* **adapter:** improve text formatting in Firebase AI content adapter and enhance function call handling ([3526a51](https://github.com/pckimlong/kai_engine/commit/3526a514ebc6cdcc7fdbf420ab1db1d39c5493ae))
* **chat_controller:** make queryEngine and postResponseEngine optional and handle null cases in processing ([a42302c](https://github.com/pckimlong/kai_engine/commit/a42302cb544ad79f2a8e602f7ab349cca6d4be62))
* **chat_controller:** update submission method to return GenerationResult and improve message handling in conversation manager ([e961841](https://github.com/pckimlong/kai_engine/commit/e9618419e5049c1d48d8f2ac96564ab4ea750eb7))
* **ci:** fix melos configuration for pub workspaces ([1ad637f](https://github.com/pckimlong/kai_engine/commit/1ad637f24e5f837959af1d658875de2dedd47f27))
* **firebase_ai_adapter:** enhance empty text handling to account for multiple parts in Firebase AI content adapter ([a42302c](https://github.com/pckimlong/kai_engine/commit/a42302cb544ad79f2a8e602f7ab349cca6d4be62))
* **generation_service:** enhance logging for candidate content and improve error handling with stack trace ([1dec488](https://github.com/pckimlong/kai_engine/commit/1dec48838b6e7d19ca0e084bb0a145294bbe7ceb))
* **generation_service:** increase max consecutive same function limit for better loop detection ([a42302c](https://github.com/pckimlong/kai_engine/commit/a42302cb544ad79f2a8e602f7ab349cca6d4be62))
* **generation_service:** remove logging of candidate content to streamline response processing ([3526a51](https://github.com/pckimlong/kai_engine/commit/3526a514ebc6cdcc7fdbf420ab1db1d39c5493ae))
* **inspector:** update content handling in editable message to ensure proper AI response modification ([e9f0f89](https://github.com/pckimlong/kai_engine/commit/e9f0f894f8c798e7aa7b432d3c7cf6fb485f3dc5))
* **kai_engine_firebase_ai:** improve content adapter formatting and empty text handling ([29d6e30](https://github.com/pckimlong/kai_engine/commit/29d6e30d5d72076db1b3484302ed59f65ef34abb))
* **kai_engine_firebase_ai:** update empty text handling for function calls and system messages ([dcfa150](https://github.com/pckimlong/kai_engine/commit/dcfa1500507503b251d430a7cd8c4fc44d8d432e))
* update SDK version to ^3.10.1 across all pubspec.yaml files ([15581dd](https://github.com/pckimlong/kai_engine/commit/15581dd86ddcf346ea6cf0937577e31d32123d01))


### Code Refactoring

* **kai_engine:** return inserted messages from addMessages ([7bdfe1d](https://github.com/pckimlong/kai_engine/commit/7bdfe1dbeefe11f7fda1ca2f50bceae885ec7be4))
