import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';

class AddEditHabitScreen extends StatefulWidget {
  final String? habitId;
  final String? existingTitle;
  final String? existingDescription;
  final List<DateTime>? existingCompletedDates;
  final String? existingCategory;

  const AddEditHabitScreen({
    Key? key,
    this.habitId,
    this.existingTitle,
    this.existingDescription,
    this.existingCompletedDates,
    this.existingCategory,
  }) : super(key: key);

  @override
  _AddEditHabitScreenState createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedFrequency = 'daily';
  String _selectedCategory = 'General';
  bool _isLoading = false;

  final List<String> _categories = [
    'General',
    'Health',
    'Fitness',
    'Study',
    'Work',
    'Finance',
    'Personal Growth',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habitId != null) {
      _titleController.text = widget.existingTitle ?? '';
      _descriptionController.text = widget.existingDescription ?? '';
      _selectedCategory = widget.existingCategory ?? 'General';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.uid;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No User Found")),
        );
        return;
      }

      final habit = HabitModel(
        id: widget.habitId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        frequency: _selectedFrequency,
        category: _selectedCategory,
        createdAt: DateTime.now(),
        completedDates: widget.habitId == null
            ? []
            : widget.existingCompletedDates ?? [],
      );

      await Provider.of<HabitProvider>(context, listen: false)
          .addOrUpdateHabit(habit);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Can't save habit. Found an error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteHabit() async {
    if (widget.habitId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.uid;

      if (userId != null) {
        await Provider.of<HabitProvider>(context, listen: false)
            .deleteHabit(widget.habitId!);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error in deleting habit. Please try again: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habitId != null;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple,
        title: Text(
          isEditing ? "Edit Habit" : "Add Habit",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Color.fromARGB(255, 255, 82, 82)),
              tooltip: "Delete Habit",
              onPressed: _deleteHabit,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Habit Name",
                        prefixIcon: const Icon(Icons.task_alt, size: 28),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter a title";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: "Habit Description",
                        prefixIcon: const Icon(Icons.description_outlined, size: 28),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: const Icon(Icons.category, size: 28),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Frequency Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedFrequency,
                      items: ['daily', 'weekly', 'monthly']
                          .map((frequency) => DropdownMenuItem(
                                value: frequency,
                                child: Text(
                                  frequency[0].toUpperCase() + frequency.substring(1),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFrequency = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Frequency',
                        prefixIcon: const Icon(Icons.repeat, size: 28),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _saveHabit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 212, 175, 218),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: Icon(
                          isEditing ? Icons.update : Icons.add,
                          size: 24,
                        ),
                        label: Text(
                          isEditing ? "Update Habit" : "Add New Habit",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
