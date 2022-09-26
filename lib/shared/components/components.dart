import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  bool isUpperCase = true,
  required String txt,
  required Function() function,
  double radius = 0.0,
}) => Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: background,
      ),
      width: width,
      child: MaterialButton(
        onPressed: function,
        child: Text(
          isUpperCase ? txt.toUpperCase() : txt,
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );

Widget defaultFormField({

  required TextEditingController myController,
  required TextInputType type,
  required String? Function(String? value) validate,
  required String label,
  required IconData prefix,
  Function(String value)? onSubmit,
  Function(String value)? onChange,
  IconData? sufix,
  Function()? sufixPress,
  bool isPassword = false,
 void Function()? onTap,
}) => TextFormField(
    controller: myController,
    keyboardType: type,
    validator: validate,
    decoration: InputDecoration(
      labelText: label,
      hintText: label,
      prefixIcon: Icon(prefix),
      suffixIcon: IconButton(
        icon: Icon(sufix),
        onPressed: sufixPress,
      ),
      border: const OutlineInputBorder(),
    ),
    obscureText: isPassword,
    onFieldSubmitted: onSubmit,
    onChanged: onChange,
  onTap:onTap ,
  );

Widget buildTaskItem(Map model,BuildContext context)=>Dismissible(
  key: Key(model['key'].toString()),
  onDismissed: (direction){
    AppCubit.get(context).deleteData(id: model['id']);
  },
  child:   Padding(
    padding: const EdgeInsets.all(15),
  
    child: Row(
  
      children: [
  
        CircleAvatar(
  
          radius: 40,
  
          child:Text(model['time'],textAlign:TextAlign.center ,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
  
        ),
  
        const SizedBox(width: 10,),
  
        Expanded(
  
          child: Column(
  
            mainAxisSize: MainAxisSize.min,
  
            crossAxisAlignment: CrossAxisAlignment.start,
  
            children: [
  
              Text(model['title'],
  
                style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
  
              Text(model['date']),
  
            ],
  
          ),
  
        ),
  
        IconButton(
  
            onPressed: (){
  
              AppCubit.get(context).updateData(status: 'done', id: model['id']);
  
            },
  
            icon: const Icon(Icons.check_box_outlined),
  
          color: Colors.green,
  
        ),
  
        IconButton(
  
            onPressed: (){
  
              AppCubit.get(context).updateData(status: 'archive', id: model['id']);
  
            },
  
            icon: const Icon(Icons.archive_outlined),
  
          color: Colors.black54,
  
        ),
  
      ],
  
    ),
  
  ),
);

Widget taskBuilder(List<Map>tasks){
  return (tasks.isNotEmpty) ? ListView.separated(
    itemBuilder: (context, index) => buildTaskItem(tasks[index],context),
    separatorBuilder: (context, index) => Container(
      height: 1,
      width: double.infinity,
      color: Colors.grey[500],
    ),
    itemCount: tasks.length,
  ) : Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Icon(Icons.menu,size: 100,color: Colors.grey),
      Text("No Tasks Yet , Please Add Some Tasks",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.grey),),
    ],
  ),);
}