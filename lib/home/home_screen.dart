import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../home/diary_list.dart';
import '../home/diary_list_screen.dart';
import '../profile/profile_screen.dart';
import '../widgets/month_selecter.dart';
import '../widgets/today_card.dart';
import '../widgets/year_selecter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int bottomIndex = 0;
  final PageController _pageController = PageController();

  // Year / Month
  int activeYearIndex = 0;
  int activeMonthIndex = DateTime.now().month - 1;
  final int currentYear = DateTime.now().year;

  // User
  String userName = "Loading...";

  final List<String> months = const [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning!";
    if (hour < 17) return "Good afternoon!";
    if (hour < 21) return "Good evening!";
    return "Good night!";
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;
    if (doc.exists) setState(() => userName = doc['name']);
  }

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    final selectedYear = currentYear - activeYearIndex;

    return Scaffold(
      backgroundColor: Colors.white,

      /// 📄 Pages
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _homePage(selectedYear),
          const DiaryListScreen(),
          const ProfileScreen(),
        ],
      ),

      /// 🔵 PREMIUM BOTTOM NAV (EMBEDDED BUTTON)
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 84,
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              _navItem(CupertinoIcons.house_fill, 0),
              _navItem(CupertinoIcons.book_fill, 1),

              /// ✍️ CENTER WRITE BUTTON (CONNECTED)
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/add-diary');
                },
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B8FF9),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5B8FF9).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.pencil,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),

              _navItem(CupertinoIcons.person_fill, 2),
            ],
          ),
        ),
      ),
    );
  }

  /// 🏠 Home Page
  Widget _homePage(int selectedYear) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ]),
                Row(children: [
                  const Icon(CupertinoIcons.bell_fill, color: Colors.blueAccent),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                ])
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TodayCard(),
          ),

          const SizedBox(height: 20),

          /// Year selector
          SizedBox(
            height: 80,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 20),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (_, index) {
                final year = currentYear - index;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => activeYearIndex = index),
                    child: YearSelecter(
                      year: year,
                      isActive: activeYearIndex == index,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          /// Month selector
          SizedBox(
            height: 40,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 20),
              scrollDirection: Axis.horizontal,
              itemCount: months.length,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => activeMonthIndex = index),
                    child: MonthSelecter(
                      month: months[index],
                      isActive: activeMonthIndex == index,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: DiaryList(
              year: selectedYear,
              month: activeMonthIndex + 1,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔘 Bottom Nav Item
  Widget _navItem(IconData icon, int i) {
    final isActive = bottomIndex == i;

    return GestureDetector(
      onTap: () {
        setState(() => bottomIndex = i);
        _pageController.jumpToPage(i);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF5B8FF9).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isActive
              ? const Color(0xFF5B8FF9)
              : Colors.black38,
        ),
      ),
    );
  }
}
