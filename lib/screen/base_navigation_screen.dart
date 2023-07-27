import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/bloc/base_navigation_cubit.dart';
import 'package:source_code/screen/account_screen.dart';
import 'package:source_code/screen/forum_list_screen.dart';
import 'package:source_code/screen/home_screen.dart';
import 'package:source_code/screen/reading_list_screen.dart';
import 'package:source_code/screen/translation_screen.dart';

class BaseNavigationScreen extends StatelessWidget {
  const BaseNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) {
          return BaseNavigationCubit();
        },
        child: _BaseNavigationScreenView());
  }
}

class _BaseNavigationScreenView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const List<Tab> _tabs = [
      Tab('Home', Icons.home_filled, HomeScreen()),
      Tab('Translation', Icons.translate, TranslationScreen()),
      Tab('Reading', Icons.library_books, ReadingListScreen()),
      Tab('Forum', Icons.forum, ForumListScreen()),
      Tab('Account', Icons.account_circle_outlined, AccountScreen()),
    ];

    return BlocBuilder<BaseNavigationCubit, BaseNavigationState>(builder: (context, state) {
      BaseNavigationCubit cubit = context.read<BaseNavigationCubit>();
      BaseNavigationState state = cubit.state;
      return Scaffold(
        body: _tabs[state.currentTabIndex].screen,
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            // Fixed
            backgroundColor: Color(0xffD9D9D9),
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black26,
            currentIndex: state.currentTabIndex,
            onTap: (index) => cubit.changeTab(index),
            items: List.generate(_tabs.length, (index) {
              Tab tab = _tabs[index];
              return BottomNavigationBarItem(
                icon: Icon(tab.icon),
                label: tab.name,
              );
            })),
      );
    });
  }
}

class Tab {
  final String name;
  final IconData icon;
  final Widget screen;

  const Tab(this.name, this.icon, this.screen);
}
