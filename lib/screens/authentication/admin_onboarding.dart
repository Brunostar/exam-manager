import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  bool isAdmin;

  OnboardingPage({super.key, required this.isAdmin});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class Department {
  String name;
  int levels;

  Department(this.name, this.levels);
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentStep = 0;
  int _numDepartments = 0;
  String _userName = '';
  int _userDepartment = 0;
  String _userLevel = '';
  List<Department> _departments = [];

  // List<String> _departmentNames = [];
  List<List<String>> _departmentLevels = [];

  final _formKey = GlobalKey<FormState>();
  final _departmentNameControllers = <TextEditingController>[];
  final _departmentLevelControllers = <List<TextEditingController>>[];

  @override
  void initState() {
    super.initState();
    _departmentNameControllers
        .addAll(List.generate(_numDepartments, (_) => TextEditingController()));
    _departmentLevelControllers.addAll(List.generate(_numDepartments,
        (_) => List.generate(4, (_) => TextEditingController())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: widget.isAdmin ? _buildAdminPage() : _buildUserPage(),
      ),
    );
  }

  Widget _buildAdminPage() {
    return Form(
        key: _formKey,
        child: _currentStep == 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 4,
                  ),
                  SizedBox(height: 16.0),
                  Text('Are you an admin?'),
                  SizedBox(height: 8.0),
                  DropdownButtonFormField(
                    value: null,
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text('Yes'),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text('No'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        widget.isAdmin = value as bool;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an option';
                      }
                      return null;
                    },
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      final formState = _formKey.currentState;
                      if (formState != null && formState.validate()) {
                        formState.save();
                        setState(() {
                          _currentStep++;
                        });
                      }
                    },
                    child: Text('Next'),
                  ),
                ],
              )
            : _currentStep == 1
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: (_currentStep + 1) / 4,
                      ),
                      const SizedBox(height: 16.0),
                      const Text('How many departments does your school have?'),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a number';
                          }
                          int? num = int.tryParse(value);
                          if (num == null || num <= 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _numDepartments = int.parse(value!);
                          _departmentNameControllers.addAll(List.generate(
                              _numDepartments, (_) => TextEditingController()));
                          _departments.addAll(List.generate((_numDepartments), (_) => Department("dep", 1)));
                        },
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentStep--;
                              });
                            },
                            child: const Text('Back'),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              final formState = _formKey.currentState;
                              if (formState != null && formState.validate()) {
                                formState.save();
                                setState(() {
                                  _currentStep++;
                                });
                              }
                            },
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ],
                  )
                : _currentStep == 2
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: (_currentStep + 1) / 4,
                          ),
                          const SizedBox(height: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int i = 0; i < _numDepartments; i++) ...[
                                Text('Department ${i + 1}'),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  controller: _departmentNameControllers[i],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a department name';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Department Name',
                                  ),
                                  onSaved: (value) {
                                    _departments[i].name = value!;
                                  },
                                ),
                                const SizedBox(height: 8.0),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a number';
                                    }
                                    int? num = int.tryParse(value);
                                    if (num == null || num <= 0) {
                                      return 'Please enter a valid number';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText:
                                        'Number of levels in this department',
                                  ),
                                  onSaved: (value) {
                                    _departments[i].levels = int.parse(value!);
                                  },
                                ),
                                const SizedBox(height: 16.0),
                              ],
                            ],
                          ),

                          const Spacer(),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _currentStep--;
                                  });
                                },
                                child: Text('Back'),
                              ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    setState(() {
                                      _currentStep++;
                                    });
                                  }
                                },
                                child: Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      )
                    : _currentStep == 3
                        ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LinearProgressIndicator(
                                      value: (_currentStep + 1) / 4,
                                    ),
                                    SizedBox(height: 16.0),
                                    for (int i = 0;
                                        i < _numDepartments;
                                        i++) ...[
                                      Text(
                                          'Department ${_departmentNameControllers[i].text}'),
                                      SizedBox(height: 8.0),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Implement file upload logic
                                        },
                                        child: Text('Upload Timetable'),
                                      ),
                                      SizedBox(height: 16.0),
                                    ],
                                    Spacer(),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _currentStep--;
                                            });
                                          },
                                          child: Text('Back'),
                                        ),
                                        Spacer(),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Implement form submission logic
                                          },
                                          child: Text('Submit'),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                        : Text('Invalid Step'));
  }

  Widget _buildUserPage() {
    // if (_currentStep == 0) {
    return Form(
      key: _formKey,
      child: _currentStep == 0
      ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
          ),
          SizedBox(height: 16.0),
          Text('What is your name?'),
          SizedBox(height: 8.0),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            onSaved: (value) {
              _userName = value!;
            },
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
              setState(() {
                _currentStep++;
              });
              }
            },
            child: Text('Next'),
          ),
        ],
      ) : _currentStep == 1
      ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
          ),
          SizedBox(height: 16.0),
          Text('Which department are you in?'),
          SizedBox(height: 8.0),
          DropdownButtonFormField(
            value: null,
            items: [
              for (var department in _departments)
                DropdownMenuItem(
                  value: department.name,
                  child: Text(department.name),
                ),
            ],
            onChanged: (value) {
              setState(() {
                _userDepartment = value as int;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a department';
              }
              return null;
            },
          ),
          Spacer(),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                child: Text('Back'),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                  setState(() {
                    _currentStep++;
                  });
                  }
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ) : _currentStep == 2
      ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
          ),
          SizedBox(height: 16.0),
          Text('Please select a class level'),
          SizedBox(height: 8.0),
          DropdownButtonFormField(
            value: null,
            items: [
              for (var level in _departmentLevels[_userDepartment])
                DropdownMenuItem(
                  value: level,
                  child: Text(level),
                ),
            ],
            onChanged: (value) {
              setState(() {
                _userLevel = value as String;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a class level';
              }
              return null;
            },
          ),
          Spacer(),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                child: Text('Back'),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Implement form submission logic
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ],
      ) : Text('Invalid Step'),
    );
  }
}
