import 'package:flutter/material.dart';
import 'package:prozync/dashboard.dart';
import 'package:prozync/profile.dart';
import 'package:prozync/project.dart';
import 'package:prozync/search.dart';

class Bottomnavbar extends StatefulWidget {
  const Bottomnavbar({super.key});

  @override
  State<Bottomnavbar> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar> {
  int index = 0;
  List<Widget> pages = [
    const Dashboard(), // Home
    const Search(), // Search
    const projects(), // Projects
    const Profile(), // Profile
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        currentIndex: index,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'projects'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ]),body: pages[index],
    );
  }
}