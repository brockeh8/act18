class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Combine incorrect + correct answers and shuffle
    List<String> options =
        List<String>.from(json['incorrect_answers'] as List<dynamic>);
    options.add(json['correct_answer'] as String);
    options.shuffle();

    return Question(
      question: json['question'] as String,
      options: options,
      correctAnswer: json['correct_answer'] as String,
    );
  }
}
