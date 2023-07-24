import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../../database/course.dart';
import '../../database/department.dart';
import 'add_course.dart';

class CourseScreen extends StatefulWidget {
  BluetoothConnection? connection;
  CourseScreen({super.key, required this.connection});

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late CourseDatabase _courseDatabase;
  List<Course> _courses = [];
  List<String> _departments = [];
  String _selectedDepartment = "ALL";
  String _selectedLevel = "ALL";
  List<Course> _filteredCourses = [];

  @override
  void initState() {
    super.initState();
    _courseDatabase = CourseDatabase.instance;
    _getCourses();
  }

  void _getCourses() async {
    _courses = await _courseDatabase.getCourses();
    _departments = _getCoursesDepartments(_courses);
    _departments.add("All Departments");
    setState(() {
      _filteredCourses = _courses;
      _selectedDepartment = _departments.last;
    });
  }

  List<String> _getCoursesDepartments(List<Course> courses) {
    List<String> departments = [];
    for (Course course in courses) {
      if (!departments.contains(course.department)) {
        departments.add(course.department);
      }
    }
    return departments;
  }

  void _applyFilter() {
    setState(() {
      _filteredCourses = _courses.where((course) {
        bool departmentFilter = _selectedDepartment == "ALL" ||
            course.department == _selectedDepartment;
        bool levelFilter = _selectedLevel == "ALL" ||
            course.level == int.parse(_selectedLevel);
        return departmentFilter && levelFilter;
      }).toList();
    });
  }

  void _editCourse(Course course) {
    // TODO: Implement editing a course
    print("Editing course");
  }

  void _deleteCourse(Course course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Course'),
          content: Text('Are you sure you want to delete this course?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await _courseDatabase.deleteCourse(course);
                _getCourses();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCoursePage()),
    ).then((value) => _getCourses());
  }

  void _sendMessage(String message) {
      if (widget.connection!.isConnected) {
        widget.connection!.output.add(Uint8List.fromList(utf8.encode("$message\r\n")));
        // connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Courses'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        child: Column(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          10), //border raiuds of dropdown button
                      boxShadow: const <BoxShadow>[
                        //apply shadow on Dropdown button
                        BoxShadow(
                          color: Color.fromRGBO(
                              170, 170, 170, 0.57), //shadow for button
                          offset: Offset(0, 4),
                          blurRadius: 3,
                          spreadRadius: 0,
                        ) //blur radius of shadow
                      ]),
                  child: Padding(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    child: DropdownButton<String>(
                      value: _selectedDepartment,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value!;
                          _applyFilter();
                        });
                      },
                      items: _departments.map((department) {
                        return DropdownMenuItem<String>(
                          value: department,
                          child: Text(department),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          10), //border raiuds of dropdown button
                      boxShadow: const <BoxShadow>[
                        //apply shadow on Dropdown button
                        BoxShadow(
                          color: Color.fromRGBO(
                              170, 170, 170, 0.57), //shadow for button
                          offset: Offset(0, 4),
                          blurRadius: 3,
                          spreadRadius: 0,
                        ) //blur radius of shadow
                      ]),
                  child: Padding(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    child: DropdownButton<String>(
                      value: _selectedLevel,
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedLevel = value!;
                        });
                        _applyFilter();
                      },
                      items: const [
                        DropdownMenuItem<String>(
                          value: "ALL",
                          child: Text("All Levels"),
                        ),
                        DropdownMenuItem<String>(
                          value: "200",
                          child: Text("Level 200"),
                        ),
                        DropdownMenuItem<String>(
                          value: "300",
                          child: Text("Level 300"),
                        ),
                        DropdownMenuItem<String>(
                          value: "400",
                          child: Text("Level 400"),
                        ),
                        DropdownMenuItem<String>(
                          value: "500",
                          child: Text("Level 500"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCourses.length,
                itemBuilder: (BuildContext context, int index) {
                  Course course = _filteredCourses[index];
                  return CourseListItem(
                    course: course,
                    onEdit: _editCourse,
                    onDelete: _deleteCourse,
                    onSendMessage: _sendMessage,
                  );
                },
              ),
            ),
          ],
        ),
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addCourse,
          tooltip: 'Add Course',
          child: Icon(Icons.add),
        ),
    );
  }
}

class CourseListItem extends StatelessWidget {
  final Course course;
  final void Function(Course course) onEdit;
  final void Function(Course course) onDelete;
  final void Function(String message) onSendMessage;

  const CourseListItem({
    Key? key,
    required this.course,
    required this.onEdit,
    required this.onDelete,
    required this.onSendMessage
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(course.title),
        subtitle: Text('${course.code}     ${course.date}'
            '\n${course.start}\t\t\t\t\t     ${course.time} hours'),
        trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            IconButton(
            onPressed: () => {
              onSendMessage('${course.code}, ${course.time}')
            },
      icon: Icon(Icons.send,
          color: Theme.of(context).primaryColor),
    ),
        PopupMenuButton(
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              child: Text('Edit'),
              onTap: () => onEdit(course),
            ),
            PopupMenuItem(
              child: Text('Delete'),
              onTap: () => onDelete(course),
            ),
          ],
        ),
      ]
      ),),
    );
  }
}