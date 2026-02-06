import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/firestore_service.dart';

class AddDiaryScreen extends StatefulWidget {
  const AddDiaryScreen({super.key});

  @override
  State<AddDiaryScreen> createState() => _AddDiaryScreenState();
}

class _AddDiaryScreenState extends State<AddDiaryScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final DateTime selectedDate = DateTime.now();

  String? locationText; // 📍 saved location

  @override
  void initState() {
    super.initState();
    _fetchLocation(); // fetch silently
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // 📍 Get user location (city, state)
  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;

      locationText =
          "${place.locality ?? ''}, ${place.administrativeArea ?? ''}"
              .trim()
              .replaceAll(RegExp(r'^,|,$'), '');
    } catch (_) {
      // silently fail – diary still saves
    }
  }

  Future<void> _saveDiary() async {
    if (titleController.text.trim().isEmpty &&
        contentController.text.trim().isEmpty) {
      return;
    }

    await FirestoreService.addDiary(
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      date: selectedDate,
      location: locationText,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Edit",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveDiary,
            child: const Text(
              "Finish",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📅 Date + Location
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.calendar,
                          size: 18, color: Color(0xFF5A8DEE)),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat("EEEE, dd MMMM yyyy")
                            .format(selectedDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5A8DEE),
                        ),
                      ),
                    ],
                  ),
                ),
                if (locationText != null) ...[
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.location_solid,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        locationText!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            /// 📝 Title
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

            /// ✍️ Content
            Expanded(
              child: TextField(
                controller: contentController,
                focusNode: focusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: "Write your thoughts here...",
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
