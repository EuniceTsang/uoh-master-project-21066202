import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/blob/account_cubit.dart';
import 'package:source_code/utils/preference.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (BuildContext context) {
      return AccountCubit();
    }, child: BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      AccountCubit cubit = context.read<AccountCubit>();
      AccountState state = cubit.state;
      return Scaffold(
        appBar: AppBar(title: Text("Account")),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showLogoutDialog(context, cubit);
          },
          backgroundColor: Colors.black,
          child: new Icon(Icons.logout, color: Colors.white),
        ),
      );
    }));
  }
}

Future<void> showLogoutDialog(BuildContext context, AccountCubit cubit) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(Preferences().username),
        content: Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop();
              cubit.logout(context);
            },
          ),
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
