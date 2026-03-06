// lib/models/coding_answer.dart
class CodingAnswer {
  final int questionId;
  final String question;
  String code;
  bool isSubmitted;
  DateTime lastModified;

  CodingAnswer({
    required this.questionId,
    required this.question,
    this.code = '',
    this.isSubmitted = false,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'question': question,
    'code': code,
    'isSubmitted': isSubmitted,
    'lastModified': lastModified.toIso8601String(),
  };

  factory CodingAnswer.fromJson(Map<String, dynamic> json) => CodingAnswer(
    questionId: json['questionId'],
    question: json['question'],
    code: json['code'] ?? '',
    isSubmitted: json['isSubmitted'] ?? false,
    lastModified: DateTime.parse(json['lastModified']),
  );

  CodingAnswer copyWith({
    String? code,
    bool? isSubmitted,
    DateTime? lastModified,
  }) {
    return CodingAnswer(
      questionId: questionId,
      question: question,
      code: code ?? this.code,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      lastModified: lastModified ?? DateTime.now(),
    );
  }
}