// users create a new habit or edit an existing habit
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
// import '../../services/firestore_service.dart';

// Accepts optional values → if provided, the screen is in edit mode; if not, it’s add mode
class AddEditHabitScreen extends StatefulWidget {
  final String? habitId;
  final String? existingTitle;
  final String? existingDescription;
  final List<DateTime>? existingCompletedDates;

  const AddEditHabitScreen({
    Key? key,
    this.habitId,
    this.existingTitle,
    this.existingDescription,
    this.existingCompletedDates,
  }) : super(key: key);

  @override
  _AddEditHabitScreenState createState() => _AddEditHabitScreenState();
}

// a form to add new habit
class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();// Form validation is handled with _formKey
  final _descriptionController = TextEditingController();// manage habit title & description. 
  String _selectedFrequency = 'daily';//  dropdown for choosing daily/weekly/monthly.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If editing, pre-fills text fields with existing values.
    if (widget.habitId != null) {
      _titleController.text = widget.existingTitle ?? '';
      _descriptionController.text = widget.existingDescription ?? '';
    }
  }

 // Disposes controllers when screen is destroyed.
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Saving Habit
  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.uid;

      if(userId == null) {
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
        createdAt: DateTime.now(),
        completedDates: widget.habitId == null
            ? []
            : widget.existingCompletedDates ?? [],
      );

      await Provider.of<HabitProvider>(context, listen: false)
          .addOrUpdateHabit(habit);

      Navigator.pop(context);// After saving, goes back (Navigator.pop).
    } 
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Can't save habit. Found an error: $e")),
      );
    } 
    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Deleting Habit
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
            .deleteHabit(widget.habitId!);// Deletes habit by ID through HabitProvider.
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
        title: Text(isEditing ? "Edit Habit" : "Add Habit"),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteHabit,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    filled: true,
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                  labelText: "Enter Habit Description",
                  filled: true,
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                items: ['daily', 'weekly', 'monthly']
                    .map((frequency) => DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency[0].toUpperCase() +
                      frequency.substring(1)),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Add Frequency',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveHabit,
                child: Text(isEditing ? "Update Already Exited Habit" : "Add A New Habit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}