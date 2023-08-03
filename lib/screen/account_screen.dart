import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:source_code/bloc/account_cubit.dart';
import 'package:source_code/utils/preference.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (BuildContext context) {
      return AccountCubit(context);
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
        body: Column(
          children: [
            ListTile(
              title: Text("Username"),
              trailing: Text(Preferences().username),
            ),
            Divider(
              height: 1,
              color: Colors.grey,
            ),
            ListTile(
              title: Text("Email"),
              trailing: Text(FirebaseAuth.instance.currentUser?.email ?? ''),
            ),
            Divider(
              height: 1,
              color: Colors.grey,
            ),
            ListTile(
              title: Text("Target reading per day"),
              trailing: Text(state.targetReading?.toString() ?? ''),
              onTap: () {
                _showTargetReadingBottomSheet(context);
              },
            ),
            Divider(
              height: 1,
              color: Colors.grey,
            ),
            ListTile(
              title: Text("Target reading time"),
              trailing: Text(state.targetTime ?? ''),
              onTap: () {
                _showTargetTimeBottomSheet(context);
              },
            )
          ],
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

void _showTargetReadingBottomSheet(BuildContext context) {
  AccountCubit cubit = context.read<AccountCubit>();
  AccountState state = cubit.state;
  int _selectedReading = state.targetReading ?? 1;
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 200,
        child: Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    cubit.clearTargetReading();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    cubit.changeTargetReading(_selectedReading);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: _selectedReading - 1),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  _selectedReading = index + 1;
                },
                children: List.generate(50, (index) {
                  return Center(child: Text((index + 1).toString()));
                }),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showTargetTimeBottomSheet(BuildContext context) {
  AccountCubit cubit = context.read<AccountCubit>();
  AccountState state = cubit.state;
  String _selectedTime = state.targetTime ?? '00:00';
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 200,
        child: Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    cubit.clearTargetTime();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    cubit.changeTargetTime(_selectedTime);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            Expanded(
                child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              minuteInterval: 1,
              use24hFormat: true,
              initialDateTime: parseTimeString(_selectedTime),
              onDateTimeChanged: (DateTime newTime) {
                String formattedHour = newTime.hour.toString().padLeft(2, '0');
                String formattedMinute = newTime.minute.toString().padLeft(2, '0');
                _selectedTime = '$formattedHour:$formattedMinute';
              },
            )),
          ],
        ),
      );
    },
  );
}

DateTime parseTimeString(String timeString) {
  DateFormat format = DateFormat("HH:mm");
  return format.parse(timeString);
}
