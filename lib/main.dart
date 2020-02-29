import 'package:flutter/material.dart';
import 'dbmanager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DbStudentManager dbmanager = new DbStudentManager();
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  Student student;
  List<Student> studList;
  int updateIndex;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("My App"),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: "Name"),
                    controller: _nameController,
                    validator: (val) =>
                        val.isNotEmpty ? null : 'Name Should Not Be Empty',
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Course"),
                    controller: _courseController,
                    validator: (val) =>
                        val.isNotEmpty ? null : 'Coourse Should Not Be Empty',
                  ),
                  RaisedButton(
                    onPressed: () {
                      _submitStudent(context);
                    },
                    child: Container(
                        width: width * 0.9,
                        child: Text(
                          'submit',
                          textAlign: TextAlign.center,
                        )),
                    textColor: Colors.white,
                    color: Colors.blueGrey,
                  ),
                  FutureBuilder(
                    future: dbmanager.getStudentList(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        studList = snapshot.data;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: studList == null ? 0 : studList.length,
                          itemBuilder: (BuildContext context, int index) {
                            Student st = studList[index];
                            return Card(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: width * 0.6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Name: ${st.name}'),
                                        Text('Course: ${st.course}'),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        _nameController.text = st.name;
                                        _courseController.text = st.course;
                                        student = st;
                                        updateIndex = index;
                                      }),
                                  IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        dbmanager.deleteStudent(st.id);
                                        setState(() {
                                          studList.removeAt(index);
                                        });
                                      }),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return CircularProgressIndicator();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitStudent(BuildContext context) {
    if (_formKey.currentState.validate()) {
      if (student == null) {
        Student st =
            Student(name: _nameController.text, course: _courseController.text);
        dbmanager.insertStudent(st).then((id) => {
              _nameController.clear(),
              _courseController.clear(),
              print('Student Added to Db ${id}')
            });
      } else {
        student.name = _nameController.text;
        student.course = _courseController.text;

        dbmanager.updateStudent(student).then((id) => {
              setState(() {
                studList[updateIndex].name = _nameController.text;
                studList[updateIndex].course = _courseController.text;
              }),
              _nameController.clear(),
              _courseController.clear(),
              student = null
            });
      }
    }
  }
}
