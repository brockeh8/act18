import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String _selectedAnswer = "";
  String _feedbackText = "";
  String? _errorMessage; // <-- added

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final questions = await ApiService.fetchQuestions();
      setState(() {
        _questions = questions;
        _currentQuestionIndex = 0;
        _score = 0;
        _answered = false;
        _selectedAnswer = "";
        _feedbackText = "";
        _loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
        _errorMessage = 'Failed to load questions. Please try again.';
      });
    }
  }

  void _submitAnswer(String selectedAnswer) {
    if (_answered) return; // ignore taps after already answered

    setState(() {
      _answered = true;
      _selectedAnswer = selectedAnswer;
      final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;

      if (selectedAnswer == correctAnswer) {
        _score++;
        _feedbackText = "Correct! The answer is $correctAnswer.";
      } else {
        _feedbackText = "Incorrect. The correct answer is $correctAnswer.";
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _answered = false;
      _selectedAnswer = "";
      _feedbackText = "";
      _currentQuestionIndex++;
    });
  }

  void _restartQuiz() {
    _loadQuestions();
  }

  Widget _buildOptionButton(String option) {
    Color? bg;

    if (_answered) {
      final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;

      if (option == correctAnswer) {
        bg = Colors.green; // correct answer
      } else if (option == _selectedAnswer && option != correctAnswer) {
        bg = Colors.red; // chosen wrong answer
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: _answered ? null : () => _submitAnswer(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg, // null = default color
        ),
        child: Text(option),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loading
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz App')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Error
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz App')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuestions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Finished
    if (_currentQuestionIndex >= _questions.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz App')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quiz Finished!\nYour Score: $_score/${_questions.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _restartQuiz,
                child: const Text('Play Again'),
              ),
            ],
          ),
        ),
      );
    }

    // During quiz
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $_score',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              question.question,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ...question.options.map((option) => _buildOptionButton(option)),
            const SizedBox(height: 20),
            if (_answered)
              Text(
                _feedbackText,
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedAnswer ==
                          _questions[_currentQuestionIndex].correctAnswer
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            if (_answered) const SizedBox(height: 12),
            if (_answered)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(
                  _currentQuestionIndex == _questions.length - 1
                      ? 'See Result'
                      : 'Next Question',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
