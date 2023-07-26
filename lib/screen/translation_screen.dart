import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/blob/translation_cubit.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return TranslationCubit();
        },
        child: _TranslationScreenView());
  }
}

class _TranslationScreenView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationCubit, TranslationState>(builder: (context, state) {
      TranslationCubit cubit = context.read<TranslationCubit>();
      TranslationState state = cubit.state;
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Translation'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: () => _showLanguageDialog(context),
                          child: Text(
                            state.language ?? 'Detect Language',
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.sync_alt_sharp,
                        size: 30,
                      ),
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: null,
                          child: Text(
                            'English',
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: TextField(
                          maxLines: 10, // Allow multi-line input
                          onChanged: (value) => cubit.updateInputText(value),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Type text to translate...',
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, minimumSize: Size(200, 40)),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          cubit.performTranslate();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Translate',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: state.translatedText),
                          maxLines: 10, // Allow multi-line input
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Translation result...',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // List of languages for the pop-up dialog
  List<String> _languages = [
    'Language 1',
    'Language 2',
    'Language 3',
    'Language 4',
  ];

  // Show the pop-up dialog with a list of languages and radio buttons
  void _showLanguageDialog(BuildContext context) {
    TranslationCubit cubit = context.read<TranslationCubit>();
    TranslationState state = cubit.state;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _languages.map((language) {
              return RadioListTile(
                title: Text(language),
                value: language,
                groupValue: state.language,
                onChanged: (value) {
                  cubit.changeLanguage(value ?? '');
                  Navigator.pop(context); // Close the dialog after selection
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
