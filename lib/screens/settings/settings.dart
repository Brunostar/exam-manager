import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../database/department.dart';
import '../../database/course.dart';
import 'excel_reader.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // List of all departments
  List<Department> departments = [];

  DepartmentDatabase departmentDb = DepartmentDatabase.instance;
  CourseDatabase courseDb = CourseDatabase.instance;

  // Controllers for adding new department
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController levelsController = TextEditingController();

  // Controller for editing department information
  TextEditingController editNameController = TextEditingController();
  TextEditingController editLevelsController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers
    codeController.dispose();
    nameController.dispose();
    levelsController.dispose();
    editNameController.dispose();
    editLevelsController.dispose();
    super.dispose();
  }

  void addDepartment() {
    // Show a dialog for adding a new department
    codeController.clear();
    nameController.clear();
    levelsController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Department'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: 'Department code',
                ),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Department name',
                ),
              ),
              TextField(
                controller: levelsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of levels',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  // Add the new department to the database
                  Department department = Department(
                    code: codeController.text,
                    name: nameController.text,
                    levels: int.parse(levelsController.text),
                  );
                  await departmentDb.insertDepartment(department);
                  // Refresh the list of departments and close the dialog
                  Navigator.of(context).pop();
                  setState(() {
                    departments.add(department);
                  });
                } catch (e) {
                  // Show an error message if the department could not be added
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content:
                            Text('Could not add department. Please try again.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog without saving changes
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void deleteDepartment(Department department) {
    // Show a confirmation dialog before deleting the department
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Department'),
          content: Text('Are you sure you want to delete ${department.name}?'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await departmentDb.deleteDepartment(department);
                  // Delete all courses associated with the department from the database
                  await courseDb.deleteCoursesByDepartment(department);
                  // Refresh the list of departments and close the dialog
                  Navigator.of(context).pop();
                  setState(() {
                    departments.remove(department);
                  });
                } catch (e) {
                  // Show an error message if the department could not be deleted
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: const Text(
                            'Could not delete department. Please try again.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog without deleting the department
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void editDepartment(Department department) {
    // Show a dialog for editing department information
    editNameController.text = department.name;
    editLevelsController.text = department.levels.toString();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Department'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editNameController,
                  decoration: InputDecoration(
                    labelText: 'Department name',
                  ),
                ),
                TextField(
                  controller: editLevelsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of levels',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    // Update the department information in the database
                    department.name = editNameController.text;
                    department.levels = int.parse(editLevelsController.text);
                    await departmentDb.updateDepartment(department);
                    // Refresh the list of departments and close the dialog
                    Navigator.of(context).pop();
                    setState(() {});
                  } catch (e) {
                    // Show an error message if the department information could not be updated
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text(
                              'Could not update department information. Please try again.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Save'),
              ),
              TextButton(
                onPressed: () {
                  // Close the dialog without saving changes
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          );
        });
  }

  // Helper function to read data from an Excel file
  Future<void> _readExcelData(String file) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExcelReader(filePath: file),
      ),
    );
  }

  // Helper function to handle file selection
  Future<void> _selectFile() async {
    // Show the file picker dialog
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xlsm', 'xlsb', 'xls'],
    );

    if (result != null) {
      // Read the selected Excel file and add the courses to the database
      File file = File(result.files.single.path!);
      await _readExcelData(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: _selectFile,
            icon: const Icon(Icons.file_upload),
            // backgroundColor: Colors.transparent,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: FutureBuilder<List<Department>>(
          future: departmentDb.getDepartments(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Department>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) {
                Department department = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.only(
                      top: 12, bottom: 12, left: 6, right: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    title: Text(department.name),
                    subtitle: Text(
                        '${department.code}    ${department.levels} levels'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => editDepartment(department),
                          icon: Icon(Icons.edit,
                              color: Theme.of(context).primaryColor),
                        ),
                        IconButton(
                          onPressed: () => deleteDepartment(department),
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 48,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ElevatedButton(
            onPressed: addDepartment,
            child: const Text(
              'Add Department',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
