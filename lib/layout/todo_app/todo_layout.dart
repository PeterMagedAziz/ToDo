import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../shared/components/components.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  final scaffoldkey = GlobalKey<ScaffoldState>();
  final formkey = GlobalKey<FormState>();
  bool isBottonSheetShown = false;
  IconData fabIcon = Icons.edit;
  final titleController = TextEditingController();
  final timeController = TextEditingController();
  final dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, Object state) {
          return Scaffold(
            key: scaffoldkey,
            appBar: AppBar(
              title: Text(
                AppCubit.get(context)
                    .titles[AppCubit.get(context).currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              // condition was like this condition: tasks.isNotEmpty
              condition: state is! AppGetDataDatabaseLoadingState,
              builder: (context) => AppCubit.get(context)
                  .screen[AppCubit.get(context).currentIndex],
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                if (AppCubit.get(context).isBottonSheetShown) {
                  if (formkey.currentState.validate()) {
                    AppCubit.get(context).insertToDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text);
                    // insertToDatabase(
                    //   title: titleController.text,
                    //   date: dateController.text,
                    //   time: timeController.text,
                    // ).then((value) {
                    //   getDataFromDatabase(database).then((value) {
                    //     Navigator.pop(context);
                    //     // setState(() {
                    //     //   tasks = value;
                    //     //   print(tasks);
                    //     //
                    //     //   fabIcon = Icons.edit;
                    //     //   isBottonSheetShown = false;
                    //     // });
                    //   });
                    // });
                  }
                } else {
                  scaffoldkey.currentState
                      ?.showBottomSheet(
                        (context) => Container(
                          color: Colors.grey[100],
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: formkey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultTextFormField(
                                  controller: titleController,
                                  type: TextInputType.text,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Title must not be empty';
                                    }
                                    return null;
                                  },
                                  label: 'Task Title',
                                  prefix: Icons.title,
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                defaultTextFormField(
                                  controller: timeController,
                                  type: TextInputType.datetime,
                                  onTap: () {
                                    showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now())
                                        .then((value) {
                                      timeController.text =
                                          value.format(context).toString();
                                      print(value.format(context));
                                    });
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Time must not be empty';
                                    }
                                    return null;
                                  },
                                  label: 'Task Time',
                                  prefix: Icons.watch_later_outlined,
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                defaultTextFormField(
                                  controller: dateController,
                                  type: TextInputType.datetime,
                                  onTap: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate:
                                                DateTime.parse('2090-12-31'))
                                        .then((value) {
                                      // dateController.text =
                                      //     value.format(context).toString();
                                      dateController.text =
                                          DateFormat.yMMMd().format(value);
                                    });
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Date must not be empty';
                                    }
                                    return null;
                                  },
                                  label: 'Task date',
                                  prefix: Icons.calendar_month_outlined,
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                      ?.closed
                      ?.then((value) {
                    AppCubit.get(context).changeBottomSheetState(
                        isShow: false, icon: Icons.edit);
                  });
                  AppCubit.get(context)
                      .changeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(
                AppCubit.get(context).fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: AppCubit.get(context).currentIndex,
              onTap: (index) {
                AppCubit.get(context).changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: ('Tasks'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle),
                  label: ('Done'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: ('Archive'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
