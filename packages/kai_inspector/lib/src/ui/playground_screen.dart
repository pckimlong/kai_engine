import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kai_engine/kai_engine.dart';
import 'package:kai_inspector/src/ui/debug_data_adapter.dart';
import 'package:prompt_block/prompt_block.dart';

/// Allow to play around with the message processing timeline
class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({
    super.key,
    required this.generationService,
    required this.data,
  });

  final TimelineOverviewData data;
  final GenerationServiceBase generationService;

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  List<CoreMessage> _requestedMessages = [];
  List<CoreMessage> _generatedMessages = [];
  @override
  void initState() {
    super.initState();

    // Initialize the requested messages with the user input
    _requestedMessages = widget.data.promptMessages!.messages.map((e) => e.coreMessage).toList();
    _generatedMessages = widget.data.generatedMessages!.messages.map((e) => e.coreMessage).toList();
  }

  String _conversationToXml(List<CoreMessage> messages) {
    final result = PromptBlock.xml('conversation').addEach(messages, (mgs) {
      return PromptBlock.xmlText(
        mgs.type.name,
        mgs.content,
        attributes: {'timestamp': mgs.timestamp.toIso8601String()},
      );
    });
    return result.toString();
  }

  /// This allows comparing two prompts and copying the result to the clipboard.
  /// this helpful to paste to other AI chatbot to analyze the differences.
  /// and provide insights for improvement.
  void _copyComparedPrompt(
    List<CoreMessage> prompt1,
    List<CoreMessage> prompts, {
    required String request,
  }) {
    final conversation1 = _conversationToXml(prompt1);
    final conversation2 = _conversationToXml(prompts);
    final result = _comparePrompt(conversation1, conversation2, request);
    _copyToClipboard(result);
  }

  void _copyConversationAnalysis(
    List<CoreMessage> requestPrompts,
    List<CoreMessage> result, {
    required String userRequest,
  }) {
    final analysis = _analyzeConversation(
      _conversationToXml(requestPrompts),
      _conversationToXml(result),
      userRequest,
    );
    _copyToClipboard(analysis);
  }

  void _copyToClipboard(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playground'),
      ),
    );
  }
}

String _comparePrompt(String con1, String con2, String userRequest) {
  return '''You are an AI conversation analyst tasked with comparing and analyzing two AI conversation histories. Your goal is to provide insights that will help improve AI responses and identify key areas of confusion or improvement. Follow these instructions carefully:

1. You will be given two AI conversation histories, each including a system prompt and subsequent interactions. These will be provided in the following format:

<conversation1>
$con1
</conversation1>

<conversation2>
$con2
</conversation2>

2. You will also receive a specific user request or purpose for the comparison:

<user_request>
$userRequest
</user_request>

3. Analyze both conversations, paying close attention to:
   a. The system prompts and how they differ
   b. The AI's responses and how well they align with the system prompts
   c. Any areas where the AI seems confused or provides inconsistent answers
   d. The overall quality and coherence of the AI's responses

4. Compare the two conversations based on the following criteria:
   a. Adherence to the system prompt
   b. Consistency of responses
   c. Clarity and coherence of answers
   d. Ability to handle complex or ambiguous queries
   e. Any specific aspects mentioned in the user request

5. In your analysis, use the following format:
   <analysis>
   [Your detailed analysis here]
   </analysis>

6. Based on your analysis, provide recommendations for improving the AI's performance. This may include:
   a. Suggestions for modifying the system prompt
   b. Identifying areas where additional training or data might be beneficial
   c. Proposing changes to the AI's response strategy

   Present your recommendations in the following format:
   <recommendations>
   [Your recommendations here]
   </recommendations>

7. If the user request asks for a specific comparison or analysis not covered in the above points, address it explicitly in a separate section:
   <specific_analysis>
   [Your analysis addressing the user's specific request]
   </specific_analysis>

8. Conclude your analysis with a summary of which conversation performed better overall and why. If elements from both conversations could be combined for an optimal result, explain how:
   <conclusion>
   [Your conclusion here]
   </conclusion>

Remember, your primary goal is to provide insights that will help improve the AI's responses and identify key areas of confusion or potential enhancement. Focus on practical, actionable feedback that can lead to tangible improvements in AI performance.

Your final output should include only the <analysis>, <recommendations>, <specific_analysis> (if applicable), and <conclusion> sections. Do not include any other text or explanations outside these tags.''';
}

String _analyzeConversation(String requestPrompts, String result, String userRequest) {
  return '''You are an AI assistant tasked with analyzing a conversation history, a generated response, and a user's request for improvement or clarification. Your goal is to provide a clear and helpful analysis to assist the user in achieving their desired outcome.

First, carefully read and analyze the following:

<prompt_history>
$requestPrompts
</prompt_history>

This is the conversation history leading up to the generated response. Pay close attention to any system prompts or specific instructions given to the AI.

Next, examine the generated response:

<generated_response>
$result
</generated_response>

Now, consider the user's request:

<user_request>
$userRequest
</user_request>

To provide a helpful analysis:

1. Identify the key elements of the prompt history, particularly any system prompts or specific instructions that influenced the generated response.

2. Analyze how well the generated response aligns with the prompt history and any given instructions.

3. Determine the user's goal based on their request. Are they seeking clarification, improvement, or a different approach?

4. Consider how the prompt history and generated response relate to the user's request.

5. Formulate clear and actionable suggestions to help the user achieve their goal. This may include:
   - Explaining why the AI generated the response it did
   - Suggesting modifications to the prompt or instructions
   - Proposing alternative approaches
   - Highlighting areas for improvement in the generated response

6. Provide a concise summary of your analysis and recommendations.

Your final output should be structured as follows:

<analysis>
1. Key observations from the prompt history
2. Assessment of the generated response
3. Understanding of the user's request
4. Suggestions for improvement or clarification
5. Summary of recommendations
</analysis>

Ensure that your analysis is clear, concise, and directly addresses the user's request. Focus on providing actionable insights that will help the user achieve their desired outcome.''';
}
