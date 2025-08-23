import 'package:kai_engine/kai_engine.dart';

/// Convert messages to XML format
String _messagesToXml(List<CoreMessage> messages) {
  final result = StringBuffer();
  for (final msg in messages) {
    final tagName = msg.type.name;
    result.writeln('<${tagName}_message timestamp="${msg.timestamp.toIso8601String()}">');
    result.writeln(msg.content);
    result.writeln('</${tagName}_message>');
  }
  return result.toString();
}

/// Utility functions for generating comparison and analysis prompts
class PlaygroundPrompts {
  /// Generates a prompt for comparing two conversations
  static String comparePrompt(
    List<CoreMessage> messages1,
    List<List<CoreMessage>> message2,
    String userRequest,
    String? appContext,
  ) {
    return '''You are an AI conversation analyst tasked with comparing and analyzing two AI conversation histories. Your goal is to provide insights that will help improve AI responses and identify key areas of confusion or improvement. Follow these instructions carefully:

1. You will be given two AI conversation histories, each including a system prompt and subsequent interactions. These will be provided in the following format:

<conversation1>
${_messagesToXml(messages1)}
</conversation1>

<conversation2>
${message2.map(_messagesToXml).join('\n')}
</conversation2>

2. You will also receive a specific user request or purpose for the comparison:

${appContext != null ? '<app_context>\n$appContext\n</app_context>\n' : ''}
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

  /// Generates a prompt for analyzing a conversation
  static String analyzeConversation(
    List<CoreMessage> requestPrompts,
    List<CoreMessage> result,
    String userRequest,
    String? appContext,
  ) {
    return '''You are an AI assistant tasked with analyzing a conversation history, a generated response, and a user's request for improvement or clarification. Your goal is to provide a clear and helpful analysis to assist the user in achieving their desired outcome.

First, carefully read and analyze the following:

<prompt_history>
${_messagesToXml(requestPrompts)}
</prompt_history>

This is the conversation history leading up to the generated response. Pay close attention to any system prompts or specific instructions given to the AI.

Next, examine the generated response:

<generated_response>
${_messagesToXml(result)}
</generated_response>

Now, consider the user's request:

${appContext != null ? '<app_context>\n$appContext\n</app_context>\n' : ''}

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
}
