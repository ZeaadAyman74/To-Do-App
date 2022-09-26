import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/cubit/states.dart';
import '../../modules/archived_tasks/archived_tasks_screen.dart';
import '../../modules/done_tasks/done_tasks_screen.dart';
import '../../modules/new_tasks/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(InitialState());

  List<Widget> tabs = [
    const NewTasksScreen(),
    const DoneTasksScreen(),
    const ArchivedTasksScreen(),
  ];
  List<String> titles = [
    "New Tasks",
    "Done Tasks",
    "Archived Tasks",
  ];
  var titleController = TextEditingController();
  var dateController = TextEditingController();
  var timeController = TextEditingController();

  static AppCubit get(context) => BlocProvider.of(context);

  int screenIndex = 0;

  void changeIndex(int index) {
    screenIndex = index;
    emit(ChangeBottomNavBarState());
  }

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archiveTasks = [];

  var database;

  void createDatabase() async {
    await openDatabase('Todo.db', version: 1, onCreate: (database, version) {
      //id integer
      //title string
      //date string
      //time string
      //status string

      print("Database created");
      database.execute(
              'CREATE TABLE tasks(id INTEGER PRIMARY KEY,title TEXT,date TEXT,time TEXT,status TEXT)')
          .then((value) {
        print("Table created");
      }).catchError((error) {
        print("Error when creating table ${error.toString()}");
      });
    }, onOpen: (database) {
      getDataFromDatabase(database);
      print("database opened");
    }).then((value) {
      database = value;
      print("Created");
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database!.transaction((txn) async {
      txn.rawInsert(
          'INSERT INTO tasks(title,date,time,status)VALUES("$title","$date","$time","new")').then((value) {
                titleController.text='';
                timeController.text='';
                dateController.text='';
        print("$value inserted successfully");
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);
      }).catchError((error) {
        print("Error when inserting new record ${error.toString()}");
      });
    });
  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archiveTasks = [];

    database!.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archiveTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  void updateData({
    required String status,
    required int id,
  }) async {
    database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?', [status, id]).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDataState());
    }).catchError((error) {
      print("Errooooooooor $error");
    });
  }

  void deleteData({
    required int id,
  }) async {
    database.rawDelete(
        'DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDataState());
    }).catchError((error) {
      print("Errooooooooor $error");
    });
  }

  bool isBottomSheetShown = false;
  var fabIcon = Icons.edit;

  void changeBottomSheetState({required fabIcon, required isBottomSheetShown}) {
    this.fabIcon = fabIcon;
    this.isBottomSheetShown = isBottomSheetShown;
    emit(FabState());
  }
}
