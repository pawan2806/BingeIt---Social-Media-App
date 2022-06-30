import 'package:bingeit/application/feedback/feedback_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  TextEditingController _feedbackController;

  @override
  void initState() {
    super.initState();
    _feedbackController = TextEditingController();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B1E2B),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            BlocConsumer<FeedbackBloc, FeedbackState>(
              listener: (context, state) {
                if (state.errorMessage.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              builder: (context, state) {
                return GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back,
                                    size: 32,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    "Send Feedback",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),

                          //const Text("Please check what type of feedback you are sending"),

                          Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                              child: TextField(
                                controller: _feedbackController,
                                maxLines: 80,
                                maxLength: 1000,
                                decoration: const InputDecoration(
                                  hintText: 'Your feedback matters.\nDont forget to rate Bingeit on PlayStore.',
                                  counter: Offstage(),
                                ),
                                onChanged: (value) {
                                  context.read<FeedbackBloc>().add(
                                        FeedbackEvent.feedbackMessageChanged(value),
                                      );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ElevatedButton(
                              onPressed: state.feedbackMessage.isEmpty
                                  ? null
                                  : () {
                                      FocusScope.of(context).unfocus();
                                      context.read<FeedbackBloc>().add(
                                            FeedbackEvent.submitPressed(),
                                          );
                                      setState(() {
                                        _feedbackController.clear();
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF6398ff),
                              ),
                              child: const Text("Submit"),
                            ),
                          ),
                        ],
                      ),
                      if (state.isSubmitting)
                        Container(
                          color: Colors.grey[900].withOpacity(0.7),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
