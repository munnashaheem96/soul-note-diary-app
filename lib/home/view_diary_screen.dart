import 'package:diary_app/home/edit_diary_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';

class ViewDiaryScreen extends StatelessWidget {
  final String diaryId;
  final String title;
  final String content;
  final DateTime date;
  final String? location;
  final DateTime? updatedAt;

  const ViewDiaryScreen({
    super.key,
    required this.diaryId,
    required this.title,
    required this.content,
    required this.date,
    this.location,
    this.updatedAt,
  });

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
          "Diary",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          /// ✏️ Edit
          IconButton(
            icon: const Icon(CupertinoIcons.pencil),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditDiaryScreen(
                    diaryId: diaryId,
                    initialTitle: title,
                    initialContent: content,
                    location: location,
                  ),
                ),
              );
              Navigator.pop(context); // refresh by reopening
            },
          ),

          /// 🗑 Delete (already implemented)
          IconButton(
            icon: const Icon(
              CupertinoIcons.trash,
              color: Colors.redAccent,
            ),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.calendar,
                        size: 16,
                        color: Color(0xFF5A8DEE),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat("EEEE, dd MMMM yyyy").format(date),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5A8DEE),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (updatedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Last edited · ${DateFormat('dd MMM yyyy • hh:mm a').format(updatedAt!)}",
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.7,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Delete Diary"),
        content: const Text("This diary will be permanently deleted."),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Delete"),
            onPressed: () async {
              Navigator.pop(context);
              await FirestoreService.deleteDiary(diaryId);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
