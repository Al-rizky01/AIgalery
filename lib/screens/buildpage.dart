import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aigalery1/screens/MyHomePage.dart';
import 'package:aigalery1/screens/UserDetailPage.dart';
import 'package:aigalery1/screens/AlbumPage.dart';
import 'package:aigalery1/screens/uploadImage_page.dart';
import 'package:aigalery1/widgets/app_bbn.dart';

class BuildPage extends StatefulWidget {
  @override
  _BuildPageState createState() => _BuildPageState();
}

class _BuildPageState extends State<BuildPage> {
  int _currentIndex = 0; // Awal: Home
  String? userIdDariLogin;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userIdDariLogin = prefs.getString('userId');
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<Widget> _pages = [
      MyHomePage(), // Home (Indeks 0)
      AlbumsPage(userId: userIdDariLogin!), // Albums (Indeks 1)
      UploadImagePage(userIdUploadters: userIdDariLogin!), // Upload (Indeks 2)
      UserDetailPage(userId: userIdDariLogin!), // Profile (Indeks 3)
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AppBBN(
        atBottom: true,
        currentIndex: _currentIndex, // Berikan indeks aktif
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
