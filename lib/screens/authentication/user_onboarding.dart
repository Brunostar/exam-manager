import 'package:flutter/material.dart';

class UserOnboarding extends StatefulWidget {
  const UserOnboarding({Key? key}) : super(key: key);

  @override
  _UserOnboardingState createState() => _UserOnboardingState();
}

class _UserOnboardingState extends State<UserOnboarding> {
  String _selectedDepartment = '';
  String _selectedLevel = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Stepper(
          currentStep: _selectedDepartment.isNotEmpty ? 1 : 0,
          steps: [
            Step(
              title: Text('Department'),
              isActive: _selectedDepartment.isEmpty,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select your department:',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 8.0),
                  DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(child: Text('Department 1'), value: 'Department 1'),
                      DropdownMenuItem(child: Text('Department 2'), value: 'Department 2'),
                      DropdownMenuItem(child: Text('Department 3'), value: 'Department 3'),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value.toString();
                      });
                    },
                    value: _selectedDepartment,
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Level'),
              isActive: _selectedDepartment.isNotEmpty,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select your level:',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 8.0),
                  DropdownButtonFormField(
                    items: [
                      DropdownMenuItem(child: Text('Level 1'), value: 'Level 1'),
                      DropdownMenuItem(child: Text('Level 2'), value: 'Level 2'),
                      DropdownMenuItem(child: Text('Level 3'), value: 'Level 3'),
                      DropdownMenuItem(child: Text('Level 4'), value: 'Level 4'),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value.toString();
                      });
                    },
                    value: _selectedLevel,
                  ),
                  SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDepartment = '';
                        _selectedLevel = '';
                      });
                    },
                    child: Text('Back'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}