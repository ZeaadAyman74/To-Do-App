import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
//import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  HomeLayout({Key? key}) : super(key: key);

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => AppCubit()..createDatabase(),
        child: BlocConsumer<AppCubit, AppStates>(
          listener: (context, state) {
            if (state is AppInsertDatabaseState) Navigator.pop(context);
          },
          builder: (context, state) {
            AppCubit cubit = AppCubit.get(context);
            return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                title: Text(cubit.titles[cubit.screenIndex]),
              ),
              body: state is AppGetDatabaseLoadingState
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : cubit.tabs[cubit.screenIndex],
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (cubit.isBottomSheetShown) {
                    if (formKey.currentState!.validate()) {
                      cubit.insertToDatabase(
                        title:cubit. titleController.text,
                        date:cubit. dateController.text,
                        time: cubit.timeController.text,

                      );
                    }
                  } else {
                    cubit.changeBottomSheetState(
                        fabIcon: Icons.add, isBottomSheetShown: true);
                    scaffoldKey.currentState!.showBottomSheet(
                          (context) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    defaultFormField(
                                        myController:cubit. titleController,
                                        type: TextInputType.text,
                                        validate: (String? value) {
                                          if (value!.isEmpty) {
                                            return 'title must not be empty';
                                          } else {
                                            return null;
                                          }
                                        },
                                        label: "Task Title",
                                        prefix: Icons.title),
                                    const SizedBox(height: 20),
                                    defaultFormField(
                                      myController: cubit.timeController,
                                      type: TextInputType.datetime,
                                      validate: (String? value) {
                                        if (value!.isEmpty) {
                                          return 'Time must not be empty';
                                        } else {
                                          return null;
                                        }
                                      },
                                      label: "Task Time",
                                      prefix: Icons.watch_later_outlined,
                                      onTap: () {
                                        showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now()).then((value) {
                                          cubit.timeController.text =
                                              value!.format(context);
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    defaultFormField(
                                        myController: cubit.dateController,
                                        type: TextInputType.datetime,
                                        validate: (String? value) {
                                          if (value!.isEmpty) {
                                            return 'Date must not be empty';
                                          } else {
                                            return null;
                                          }
                                        },
                                        label: "Task Date",
                                        prefix: Icons.date_range_outlined,
                                        onTap: () {
                                          showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate:
                                                DateTime.parse('2023-07-19'),
                                          ).then((value) {
                                           cubit. dateController.text =
                                                DateFormat.yMMMd()
                                                    .format(value!);
                                          });
                                        }),
                                  ],
                                ),
                              ),
                            );
                          },
                          elevation: 20,
                        )
                        .closed
                        .then((value) {
                          cubit.changeBottomSheetState(
                              fabIcon: Icons.edit, isBottomSheetShown: false);
                        });
                  }
                },
                child: Icon(cubit.fabIcon),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: cubit.screenIndex,
                onTap: (index) {
                  cubit.changeIndex(index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu),
                    label: "Tasks",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.check),
                    label: "Done",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined),
                    label: "Archived",
                  )
                ],
              ),
            );
          },
        ));
  }
}
