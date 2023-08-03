import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:source_code/bloc/history_cubit.dart';
import 'package:source_code/models/article.dart';
import 'package:source_code/models/word.dart';
import 'package:source_code/utils/constants.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return HistoryCubit(context);
        },
        child: _HistoryScreenView());
  }
}

class _HistoryScreenView extends StatelessWidget {
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
                child: state.loading ? _buildLoadingBlock() : _buildDictionaryList(context),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Reading",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                  flex: 3,
                  child: state.loading ? _buildLoadingBlock() : _buildReadingList(context)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLoadingBlock() {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Card(child: Container(color: Colors.white, width: double.infinity, height: 150)));
  }

  Widget _buildDictionaryList(BuildContext context) {
    HistoryCubit cubit = context.read<HistoryCubit>();
    HistoryState state = cubit.state;
    return state.wordHistory.isEmpty
        ? Center(
            child: Text(
            "No history found",
            style: TextStyle(color: Colors.grey, fontSize: 20),
          ))
        : ListView.separated(
            // Disable scrolling
            shrinkWrap: true,
            itemCount: state.wordHistory.length,
            itemBuilder: (BuildContext context, int index) {
              Word word = state.wordHistory[index];
              return ListTile(
                dense: true,
                title: Text(
                  word.word,
                  style: TextStyle(fontSize: 15),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                ),
                onTap: () {
                  Navigator.pushNamed(context, Constants.routeDictionary, arguments: word.word);
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) => Divider(
              height: 1,
              color: Colors.grey,
            ),
          );
  }

  Widget _buildReadingList(BuildContext context) {
    HistoryCubit cubit = context.read<HistoryCubit>();
    HistoryState state = cubit.state;
    return state.articleHistory.isEmpty
        ? Center(
            child: Text(
            "No history found",
            style: TextStyle(color: Colors.grey, fontSize: 20),
          ))
        : ListView.builder(
            itemCount: state.articleHistory.length,
            itemBuilder: (context, index) {
              Article article = state.articleHistory[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                    child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, Constants.routeReading, arguments: article);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        article.imageUrl.isEmpty ? Constants.placeholderPicUrl : article.imageUrl,
                        // Replace with your own image path
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.fitWidth, // Adjusts the image within the card
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          article.abstract,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
              );
            });
  }
}
