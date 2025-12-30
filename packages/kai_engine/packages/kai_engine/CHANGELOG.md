# Changelog

## [2.0.0](https://github.com/pckimlong/kai_engine/compare/kai_engine-v1.0.0...kai_engine-v2.0.0) (2025-12-30)


### ⚠ BREAKING CHANGES

* **kai_engine:** GenerationServiceBase and implementations now return GenerationResult instead of String. GenerationResult.requestMessage is replaced by requestMessages.
* **kai_engine:** DebugGenerationConfig no longer exposes tokenCount. Use GenerationUsage.tokenCount instead.
* **kai_engine:** GenerationResult factory now requires a `usage` parameter (nullable). Update call sites to pass `usage: null` or a GenerationUsage instance.
* **kai_engine:** addMessages now returns Future<IList<CoreMessage>> (was Future<void>). Generation invocations are no longer serialized.
* **kai_engine:** CoreMessage now requires a timestamp. Call sites must provide it or use factory constructors that auto-populate it.
* **api:** remove ConversationManager placeholder APIs; rename PostResponseEngine.process param to `requestPrompts`; remove input transformer from `PromptTemplate.input`; generated Freezed API for `PromptTemplate.input` updated.
* **api:** ParallelContextBuilder.build now requires (QueryContext input, IList<CoreMessage> context) PostResponseEngine.process now requires a QueryContext input parameter CoreMessageFirebaseExtension.generationUsage now returns Map<String, dynamic>? instead of GenerationUsage?

### Features

* Add session dashboard and token analytics tabs with detailed metrics and insights ([4014175](https://github.com/pckimlong/kai_engine/commit/40141754c6eb19a35851c09b5d652bc4c02f480e))
* **ai:** implement smart input with core insights ([79f1947](https://github.com/pckimlong/kai_engine/commit/79f1947392fbe572528f29737813e4bd191f5f41))
* **api:** enrich builder and post engine params ([6595083](https://github.com/pckimlong/kai_engine/commit/6595083e66f6d28d14109b75c0aed3fd64d420d5))
* **chat:** add reset functionality to cancel token and improve debug logging ([ea1db42](https://github.com/pckimlong/kai_engine/commit/ea1db42d34595811ef235d25b9a4c453c23dabe5))
* **chat:** reset cancel token on submission and expose getAllMessages method ([76cea8e](https://github.com/pckimlong/kai_engine/commit/76cea8e9c5d4f30643452f8e319306552ab3b88b))
* **context_engine:** enhance ContextEngineOutput to include final user message and update related logic ([e54d00d](https://github.com/pckimlong/kai_engine/commit/e54d00d78fc4943ca883bdce1624d6fde7c25a98))
* **inspector:** add edit and generate screen with message bubbles for playground ([799ac03](https://github.com/pckimlong/kai_engine/commit/799ac0371c855e9aa7bc3b54a83e8a24b7098d91))
* **inspector:** add prompt and generated messages logging with UI debugging ([3f78bb1](https://github.com/pckimlong/kai_engine/commit/3f78bb133f97d07213baf3213171d88f15f8d7f0))
* **inspector:** enhance system with AI response tracking and mobile-responsive UI ([6bc4639](https://github.com/pckimlong/kai_engine/commit/6bc4639a3133f1a11862858e7b3ab96b821005e5))
* **inspector:** implement comprehensive prompt pipeline extraction and debugging UI ([028ec0b](https://github.com/pckimlong/kai_engine/commit/028ec0b1c2013cd0fcd095750e19e5d8dd2d9a6e))
* **inspector:** implement DefaultKaiInspector and refactor inspector system ([b348e54](https://github.com/pckimlong/kai_engine/commit/b348e54790b145915490a9469bf9b61505bbb7ec))
* **inspector:** implement managed timeline steps and responsive debug UI ([b0c249b](https://github.com/pckimlong/kai_engine/commit/b0c249ba0daa7b600c8e06be60b00178f8075414))
* **inspector:** implement nested step tracking and step updates ([5f2cc89](https://github.com/pckimlong/kai_engine/commit/5f2cc8996318d288a1a0b43e17384e9dcfe37024))
* **kai_engine/debug:** add token cost tracking and configuration UI ([7b72fea](https://github.com/pckimlong/kai_engine/commit/7b72fea89645e91744eb7077f2a505cf8a5e6e99))
* **kai_engine:** add debug tracking to builders and engine ([7636c04](https://github.com/pckimlong/kai_engine/commit/7636c045ab8309a673f22769c68d034ed7f3a34d))
* **kai_engine:** add debug tracking to post-response engine ([f9610a3](https://github.com/pckimlong/kai_engine/commit/f9610a300014fde29b31b0bfdfc79c6fe7b61777))
* **kai_engine:** add input message ID to context builder interfaces and update related implementations ([3ec30e1](https://github.com/pckimlong/kai_engine/commit/3ec30e1efbfb64724881598c4d4a9a96797103dd))
* **kai_engine:** add inspectPhase method for streamlined phase execution with error handling ([a58f470](https://github.com/pckimlong/kai_engine/commit/a58f4701a71c85f63dc8fcee8a0b609c7bc49772))
* **kai_engine:** add message debug tracking system and UI ([1476fee](https://github.com/pckimlong/kai_engine/commit/1476fee211bd2f9120765dd1685a6fb287f624c1))
* **kai_engine:** add token breakdown and unify token count usage ([a09cc8a](https://github.com/pckimlong/kai_engine/commit/a09cc8ae5523b52f006c864f876fed04f29cb01d))
* **kai_engine:** add tooling method with function call support ([0ccd71b](https://github.com/pckimlong/kai_engine/commit/0ccd71b5137218034163c6b89373e3dd629d0685))
* **kai_engine:** add usage metrics to generation results ([42e1f7a](https://github.com/pckimlong/kai_engine/commit/42e1f7a0548970282942cb6693011e0ac17ef1f6))
* **kai_engine:** refactor chat controller and context builder with immutable collections ([d18d043](https://github.com/pckimlong/kai_engine/commit/d18d043e02e145a7046fbafc64e9270e04cfa466))
* **kai_engine:** require timestamp on CoreMessage and persist it ([7d3b034](https://github.com/pckimlong/kai_engine/commit/7d3b03439232200e4db27358f1f842693fb2ce05))
* **kai_engine:** support background context messages ([627c89d](https://github.com/pckimlong/kai_engine/commit/627c89d479a1ede4386042cafe8edcd7b76bec03))
* **kai_engine:** update GenerationResult model and service interfaces ([f5eb7a7](https://github.com/pckimlong/kai_engine/commit/f5eb7a701eb645ae623cb3f18cfcb7947950ecc6))
* **prompt_block:** introduce prompt block package with structured prompt building capabilities ([466f3c5](https://github.com/pckimlong/kai_engine/commit/466f3c5bddd7b36607db79e811e58942f722a59f))
* **section:** add dynamic content building and conditional rendering features ([501d40c](https://github.com/pckimlong/kai_engine/commit/501d40c3b573ae47890b1c3dc913fd060d14485e))
* **section:** enhance Section class with rendering control and practical usage examples ([935764d](https://github.com/pckimlong/kai_engine/commit/935764d76447ac81972c277a78d077a1e7b37614))


### Bug Fixes

* **ai_generation_phase:** simplify class definition and streamline exception handling ([379f5bb](https://github.com/pckimlong/kai_engine/commit/379f5bbdad0fcd8326f55296222ce6438d4641a1))
* **chat_controller:** make queryEngine and postResponseEngine optional and handle null cases in processing ([a42302c](https://github.com/pckimlong/kai_engine/commit/a42302cb544ad79f2a8e602f7ab349cca6d4be62))
* **chat_controller:** update submission method to return GenerationResult and improve message handling in conversation manager ([e961841](https://github.com/pckimlong/kai_engine/commit/e9618419e5049c1d48d8f2ac96564ab4ea750eb7))
* **firebase_ai_adapter:** enhance empty text handling to account for multiple parts in Firebase AI content adapter ([a42302c](https://github.com/pckimlong/kai_engine/commit/a42302cb544ad79f2a8e602f7ab349cca6d4be62))
* **generation_service:** increase max consecutive same function limit for better loop detection ([a42302c](https://github.com/pckimlong/kai_engine/commit/a42302cb544ad79f2a8e602f7ab349cca6d4be62))
* update SDK version to ^3.10.1 across all pubspec.yaml files ([15581dd](https://github.com/pckimlong/kai_engine/commit/15581dd86ddcf346ea6cf0937577e31d32123d01))


### Code Refactoring

* **api:** remove placeholder messaging and rename params ([0096dba](https://github.com/pckimlong/kai_engine/commit/0096dbac85d1a1538aefa0342f0b42998332f611))
* **kai_engine:** return inserted messages from addMessages ([7bdfe1d](https://github.com/pckimlong/kai_engine/commit/7bdfe1dbeefe11f7fda1ca2f50bceae885ec7be4))
