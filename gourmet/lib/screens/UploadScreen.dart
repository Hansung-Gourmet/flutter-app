import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gourmet_app/screens/threadScreen.dart';
import 'loginScreen.dart';
import 'mapScreen.dart';
import 'myPageScreen.dart';

class UploadScreen extends StatefulWidget {
  final int selected;  // final로 변경

  UploadScreen(this.selected);  // 생성자 간소화

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late int _selectedIndex;  // null 안전성을 위해 late 사용

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selected;
  }

  // DocumentSnapshot을 반환하도록 수정
  Future<DocumentSnapshot> _loadUserData() async {
    String userUid = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userUid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Gourmet",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
              onPressed: ()async{
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route)=>false,
                );
              },
              icon: Icon(Icons.logout))

        ],
      ),
      drawer: FutureBuilder<DocumentSnapshot>(
        future: _loadUserData(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Drawer(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Drawer(
              child: Center(child: Text('오류가 발생했습니다: ${snapshot.error}')),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Drawer(
              child: Center(child: Text('데이터를 찾을 수 없습니다')),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(userData["Nickname"] ?? "사용자"),
                  accountEmail: Text(userData["Email"] ?? "이메일 없음"),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("마이페이지"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyPageScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      body: const Text("data1"),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: '지도',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '추가',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            label: '그리드',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MapScreen(index)),
                  (route) => false,
            );
          } else if (index == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => UploadScreen(index)),
                  (route) => false,
            );
          } else if (index == 2) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ThreadScreen(index)),
                  (route) => false,
            );
          }
        },
        showSelectedLabels: false,  // 선택된 아이템의 라벨 숨기기
        showUnselectedLabels: false,  // 선택되지 않은 아이템의 라벨 숨기기
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}