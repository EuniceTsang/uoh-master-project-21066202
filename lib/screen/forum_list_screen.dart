import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/blob/forum_list_cubit.dart';

class ForumListScreen extends StatelessWidget {
  const ForumListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return ForumListCubit();
        },
        child: _ForumListScreenView());
  }
}

class _ForumListScreenView extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String testText =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";
  TabBar _tabBar = TabBar(
    tabs: [
      Tab(text: 'New post'),
      Tab(text: 'My post'),
    ],
    indicatorColor: Color(0xffFFDF8B),
    labelColor: Color(0xffFFDF8B),
    unselectedLabelColor: Colors.black,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumListCubit, ForumListState>(builder: (context, state) {
      ForumListCubit cubit = context.read<ForumListCubit>();
      ForumListState state = cubit.state;
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Forum"),
            bottom: PreferredSize(
                preferredSize: _tabBar.preferredSize,
                child: ColoredBox(color: Colors.white, child: _tabBar)),
          ),
          body: TabBarView(
            children: [
              _buildThreadList(),
              _buildThreadList()
            ],
          ),
        ),
      );
    });
  }

  Widget _buildThreadList(){
    return ListView.builder(itemCount:20, itemBuilder: (context, index){
      return Card(
        child: ListTile(
          title: Text(testText.substring(0, 10),
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Row(
            children: [Expanded(child: Text("by Eren")), Text("1m")],
          ),
          trailing:
          SizedBox(
            width: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 20,
                    ),
                    Text("100")
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 20,
                    ),
                    Text("100")
                  ],
                )
              ],
            ),
          ),
          onTap: () {},
        ),
      );
    });
  }
}
