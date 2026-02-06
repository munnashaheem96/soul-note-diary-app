import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class EditDiaryScreen extends StatefulWidget {
  final String diaryId;
  final String initialTitle;
  final String initialContent;
  final String? location;

  const EditDiaryScreen({
    super.key,
    required this.diaryId,
    required this.initialTitle,
    required this.initialContent,
    this.location,
  });

  @override
  State<EditDiaryScreen> createState() => _EditDiaryScreenState();
}

class _EditDiaryScreenState extends State<EditDiaryScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _updateDiary() async {
    if (titleController.text.trim().isEmpty &&
        contentController.text.trim().isEmpty) {
      return;
    }

    await FirestoreService.updateDiary(
      diaryId: widget.diaryId,
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      location: widget.location,
    );

    if (!mounted) return;
    Navigator.pop(context, true); // 👈 tell view to refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Edit Diary",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _updateDiary,
            child: const Text(
              "Save",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF5A8DEE),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "Diary title",
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            Divider(color: Colors.grey.shade300),
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: "Write your thoughts...",
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
