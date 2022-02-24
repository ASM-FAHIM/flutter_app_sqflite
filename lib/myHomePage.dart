import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dbManager.dart';
import 'dataModelClass.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Future<DataModel> submitData(int id, String tasks) async{
    var response = await http.post(Uri.https('flutterapi.brotherdev.com', 'syncapi.php'),
    body: {
     'id' : id,
     'workNote': tasks
    });
    var data = response.body;
    print(data);
    if(response.statusCode == 201){
      return DataModel.fromJson(jsonDecode(response.body));
      // String responseString = response.body;
      // DataModel.fromJson(responseString as Map<String, dynamic>);
    }
    else{
      throw Exception("Failed to ceate album");
    }

    // if (response.statusCode == 201) {
    //   // If the server did return a 201 CREATED response,
    //   // then parse the JSON.
    //   return Album.fromJson(jsonDecode(response.body));
    // } else {
    //   // If the server did not return a 201 CREATED response,
    //   // then throw an exception.
    //   throw Exception('Failed to create album.');
    // }

}

class _MyHomePageState extends State<MyHomePage> {

  late DataModel _dataModel;

  List<Map<String, dynamic>> taskList = [];
  bool _isLoading = true;

  //assigning task to
  void getTaskList() async{
    final getData = await DbManager.getTasks();
    setState(() {
      taskList = getData ;
      taskList = taskList.reversed.toList();
      print(taskList);
      print(taskList.length);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    getTaskList();
    super.initState();
  }

  final TextEditingController _taskController = TextEditingController();

  //add Task
  void selectedTask(int? id) async{
    if (id != null) {
      final selectedId =
      taskList.firstWhere((element) => element['id'] == id);
      _taskController.text = selectedId['workList'];
    }

    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            titlePadding: const EdgeInsets.only(top: 0, left: 0, right: 0),
            contentPadding: const EdgeInsets.only(top: 12, left: 0, bottom: 10),
            insetPadding: const EdgeInsets.symmetric(horizontal: 15),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            title: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 4,),
                    Text('Add new Task', style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    InkWell(
                      onTap: (){
                        print('Inkwell pressed');
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.close_sharp, size: 30,),
                    ),
                  ],
                ),
              ),
            ),
            content: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    ListBody(
                      children: [
                        TextField(
                          controller: _taskController,
                          decoration:  InputDecoration(hintText: 'Enter your task'),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                            onPressed: () async{
                              if(id == null){
                                await addTasks();
                              }
                              if( id != null){
                                await updateTask(id);
                              }
                              _taskController.clear();
                              Navigator.pop(context);
                              print('elevated pressed');
                            }, child: Text(id == null ? 'Create' : 'Update'))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  //add task to list
  Future<void> addTasks() async{
    await DbManager.addTask(_taskController.text);
    getTaskList();
  }

  //update task list
  Future<void> updateTask(int id) async{
    await DbManager.updateTask(id, _taskController.text);
    getTaskList();
  }

  //delete task list
  Future<void> deleteTask(int id) async{
    await DbManager.deleteTasks(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted the user!'),
    ));
    getTaskList();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Task List'),
        actions: [
          GestureDetector(
            onTap: () {
              print('add pressed');
              _taskController.clear();
              selectedTask(null);
              // nameController.clear();
              // selectedUser(null);
            },
            child: Row(
              children: const [
                Text("Add"),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.add_box_outlined,
                  size: 40,
                ),
              ],
            ),
          ),
          SizedBox(width: 20,),
          GestureDetector(
            onTap: ()  async{
              print('sync pressed');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Successfully synced '),
              ));
              int id = taskList.indexWhere((element) => element ['id'] == 1);
              String task = _taskController.text;
              DataModel data = await submitData(id, task);
              setState(() {
                _dataModel = data;
              });

            },
            child: Row(
              children: const [
                Text("Add"),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.sync_rounded,
                  size: 40,
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
            child: CircularProgressIndicator(),
          )
          : ListView.builder(
            itemCount: taskList.length,
            itemBuilder: (context, index)
            => Card(
              margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskList[index]['workList'],
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.indigo,
                        ),
                        onPressed: () =>
                           selectedTask(taskList[index]['id']),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              deleteTask(taskList[index]['id']) ,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              ),
        ),
      ),
    );
  }
}
