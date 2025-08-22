// Run after the response is generated
// we can use this to perform same enhancements on the response
import 'package:kai_engine/kai_engine.dart';

abstract base class PostResponseEngineBase
    extends KaiPhase<PostResponseEngineInput, void> {
  @override
  Future<void> execute(PostResponseEngineInput input);
}
