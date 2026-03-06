// lib/models/coding_question.dart
class CodingQuestion {
  final int id;
  final String difficulty;
  final int points;
  final String question;
  final String exampleInput;
  final String exampleOutput;
  final String? starterCode;

  CodingQuestion({
    required this.id,
    required this.difficulty,
    required this.points,
    required this.question,
    required this.exampleInput,
    required this.exampleOutput,
    this.starterCode,
  });

  factory CodingQuestion.fromFirestore(Map<String, dynamic> json) {
    return CodingQuestion(
      id: json['id'],
      difficulty: json['difficulty'] ?? 'medium',
      points: json['points'] ?? 
          (json['difficulty'] == 'easy' ? 10 :
           json['difficulty'] == 'medium' ? 15 : 25),
      question: json['question'],
      exampleInput: json['example_input'] ?? '',
      exampleOutput: json['example_output'] ?? '',
      starterCode: json['starterCode'],
    );
  }
}