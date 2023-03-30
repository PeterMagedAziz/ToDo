import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/shared/cubit/states.dart';

import '../../modules/todo_app/archived_tasks/archived_tasks_screen.dart';
import '../../modules/todo_app/done_tasks/done_tasks_screen.dart';
import '../../modules/todo_app/new_tasks/new_tasks_screen.dart';


class AppCubit extends Cubit<AppStates> {
  AppCubit() : super (AppInitialState());
  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  List<Widget> screen = [
    const NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen(),
  ];
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];
  void changeIndex (int index)
  {
    currentIndex= index;
    emit(AppChangeBottomNavBarState());
  }

   Database database;

  bool isBottonSheetShown = false;
  IconData fabIcon = Icons.edit;



  Future<String> getName() async {
    return 'Peter Maged';
  }

  void updateData(
      {
     String status,
     int id,
      }
      ) async {
      await database.rawUpdate(
        'UPDATE tasks SET status = ?  WHERE id = ?',
        [ status , '$id']
      ).then((value) {
        getDataFromDatabase(database);
        emit(AppUpdateDatabaseState());
      });

  }
  void deleteData(
      {
         int id,
      }
      ) async {
    await database.rawDelete(
        'DELETE FROM tasks WHERE id = ?', [id],

    ).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });

  }

  void createDatabase()  {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database
            .execute(
            'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT,time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('i did error in creating table ${error.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

   insertToDatabase(
      { String title,
         String time,
         String date}) async {
     await database.transaction((txn) {
      return txn
          .rawInsert(
          'INSERT INTO tasks (title , date , time , status) VALUES ("$title", "$date", "$time", "new")')
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertDatabaseState());

        getDataFromDatabase(database);

      }).catchError((error) {
        print('Error When Inserting  new Records ${error.toString()}');
      });
    });
  }

  // void getDataFromDatabase(database)  {
  //
  //   emit(AppGetDataDatabaseLoadingState());
  //
  //   database.query('tasks').then((value) {
  //      newTasks = value;
  //      print(newTasks);
  //
  //      value.forEach((element)
  //      {
  //        if(element['status'] == 'new') {
  //          newTasks.add(element);
  //        } else  if(element['status'] == 'done') {
  //           doneTasks.add(element);
  //         } else {
  //           archivedTasks.add(element);
  //         }
  //      });
  //      emit(AppGetDataDatabaseState());
  //   });
  // }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppGetDataDatabaseLoadingState());

    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });

      emit(AppGetDataDatabaseState());
    });
  }
  void changeBottomSheetState ({ bool isShow,  IconData icon}) {
    isBottonSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }
  bool isDark = false;

  void changeAppMode()
  {

    {
      isDark = !isDark;
        emit(NewsChangeAppModeStates());
    }

  }

}
