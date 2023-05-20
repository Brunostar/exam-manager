import 'package:flutter/material.dart';

class AddCoursePage extends StatefulWidget {
  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  String _department = '';
  String _courseCode = '';
  String _courseName = '';
  int _credits=0;
  DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Department',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a department';
                  }
                  return null;
                },
                onSaved: (value) {
                  _department = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Course Code',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a course code';
                  }
                  return null;
                },
                onSaved: (value) {
                  _courseCode = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Course Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a course name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _courseName = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Credits',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the number of credits';
                  }
                  return null;
                },
                onSaved: (value) {
                  _credits = int.parse(value!);
                },
              ),
              SizedBox(height: 16.0),
              Text('Date'),
              SizedBox(height: 8.0),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _date) {
                    setState(() {
                      _date = picked;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    _date == null ? 'Select Date' : '${_date.year}-${_date.month}-${_date.day}',
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text('Start Time'),
              SizedBox(height: 8.0),
              InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null && picked != _startTime) {
                    setState(() {
                      _startTime = picked;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    _startTime == null ? 'Select Start Time' : '${_startTime.hour}:${_startTime.minute}',
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text('End Time'),
              SizedBox(height: 8.0),
              InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null && picked != _endTime) {
                    setState(() {
                      _endTime = picked;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    _endTime == null ? 'Select End Time' : '${_endTime.hour}:${_endTime.minute}',
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState?.save();
                    // TODO: Save the course data to the database
                    Navigator.pop(context);
                  }
                },
                child: Text('Add Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}