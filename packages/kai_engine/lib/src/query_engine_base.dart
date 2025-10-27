import 'package:kai_engine/kai_engine.dart';

abstract base class QueryEngineBase
    extends KaiPhase<QueryEngineInput, QueryContext> {
  // Force implementations to override the execute method
  @override
  Future<QueryContext> execute(QueryEngineInput input);
}
