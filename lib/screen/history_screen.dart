import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/blob/history_cubit.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return HistoryCubit();
        },
        child: _HistoryScreenView());
  }
}

class _HistoryScreenView extends StatelessWidget {
  List<String> testHistoryWords = [
    "condemn",
    "fetter",
    "forge",
    "odour",
    "condemn",
    "fetter",
    "forge",
    "odour"
  ];
  String testText =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(builder: (context, state) {
      HistoryCubit cubit = context.read<HistoryCubit>();
      HistoryState state = cubit.state;
      return Scaffold(
        appBar: AppBar(title: Text("History")),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Dictionary",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildDictionaryList(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Reading",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(flex: 3, child: _buildReadingList()),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDictionaryList() {
    return ListView.separated(
      // Disable scrolling
      shrinkWrap: true,
      itemCount: testHistoryWords.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          dense: true,
          title: Text(
            testHistoryWords[index],
            style: TextStyle(fontSize: 15),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
          ),
          onTap: () {},
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: 1,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildReadingList() {
    return ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  'https://www.nytimes.com/images/2023/07/09/arts/09Byrd-Anniversary-illo/09Byrd-Anniversary-illo-blog427.jpg',
                  // Replace with your own image path
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.fitWidth, // Adjusts the image within the card
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    testText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    testText,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )),
          );
        });
  }
}
