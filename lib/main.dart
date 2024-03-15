import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Flashcard {
  String question;
  String answer;

  Flashcard({required this.question, required this.answer});

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      question: json['question'],
      answer: json['answer'],
    );
  }
}

class AddQuizScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const AddQuizScreen({Key? key, required this.flashcards}) : super(key: key);

  @override
  _AddQuizScreenState createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  late List<bool> showAnswer;

  @override
  void initState() {
    super.initState();
    showAnswer = List<bool>.filled(widget.flashcards.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Mode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: widget.flashcards.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(widget.flashcards[index].question),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String correctAnswer = widget.flashcards[index].answer;
                  return StatefulBuilder(
                    builder: (BuildContext context, setState) {
                      return AlertDialog(
                        title: Text(widget.flashcards[index].question),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              enabled: !showAnswer[index],
                              decoration: const InputDecoration(
                                labelText: 'Your Answer',
                              ),
                              onSubmitted: (String value) {
                                if (value.trim() == correctAnswer) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Correct!'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Answer Incorrect!'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                            Visibility(
                              visible: !showAnswer[index],
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    showAnswer[index] = true;
                                  });
                                },
                                child: const Text('Show Answer'),
                              ),
                            ),
                            Visibility(
                              visible: showAnswer[index],
                              child: Text(
                                'Correct Answer: $correctAnswer',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class EditFlashcardScreen extends StatelessWidget {
  final Flashcard flashcard;
  final TextEditingController questionController;
  final TextEditingController answerController;

  EditFlashcardScreen({Key? key, required this.flashcard})
      : questionController = TextEditingController(text: flashcard.question),
        answerController = TextEditingController(text: flashcard.answer),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Flashcard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Answer'),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      Flashcard(
                        question: questionController.text,
                        answer: answerController.text,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddFlashcardScreen extends StatelessWidget {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  AddFlashcardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Flashcard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Answer'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  Flashcard(
                    question: questionController.text,
                    answer: answerController.text,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({Key? key}) : super(key: key);

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Flashcard> flashcards = [];

  @override
  void initState() {
    super.initState();
    loadFlashcards();
  }

  Future<void> loadFlashcards() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      List<dynamic> jsonList = jsonDecode(contents);
      setState(() {
        flashcards = jsonList.map((item) => Flashcard.fromJson(item)).toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error loading flashcards: $e");
      }
    }
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/flashcards.json');
  }

  Future<void> saveFlashcards() async {
    final file = await _localFile;
    await file.writeAsString(jsonEncode(flashcards));
  }

  Future<void> editFlashcard(int index) async {
    final updatedFlashcard = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFlashcardScreen(
          flashcard: flashcards[index],
        ),
      ),
    );
    if (updatedFlashcard != null) {
      setState(() {
        flashcards[index] = updatedFlashcard;
        saveFlashcards();
      });
    }
  }

  Future<void> deleteFlashcard(int index) async {
    bool delete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content:
              const Text('Are you sure you want to delete this flashcard?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (delete == true) {
      setState(() {
        flashcards.removeAt(index);
        saveFlashcards();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
      ),
      body: ListView.builder(
        itemCount: flashcards.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(flashcards[index].question),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(flashcards[index].question),
                    content: Text(flashcards[index].answer),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Options'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          editFlashcard(index);
                        },
                        child: const Text('Edit'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          deleteFlashcard(index);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final newFlashcard = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFlashcardScreen(),
                ),
              );
              if (newFlashcard != null) {
                setState(() {
                  flashcards.add(newFlashcard);
                  saveFlashcards();
                });
              }
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              final newFlashcard = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddQuizScreen(flashcards: flashcards),
                ),
              );
              if (newFlashcard != null) {
                setState(() {
                  flashcards.add(newFlashcard);
                  saveFlashcards();
                });
              }
            },
            child: const Icon(Icons.quiz),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue, // Text color for ElevatedButton
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue, // Floating action button color
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue, // Text color for TextButton
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // App bar color
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(background: Colors.lightBlueAccent),
      ),
      home: const FlashcardScreen(),
    );
  }
}
