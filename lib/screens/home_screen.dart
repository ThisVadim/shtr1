import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shtr1/screens/account_screen.dart';
import 'package:shtr1/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Главная страница'),
        actions: [
          IconButton(
            onPressed: () {
              if (user == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountScreen()),
                );
              }
            },
            icon: Icon(
              Icons.person,
              color: (user == null) ? const Color.fromARGB(255, 0, 0, 0) : Colors.yellow,
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Слайдер
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('home_slider').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('Нет данных для отображения');
                }

                final docs = snapshot.data!.docs;

                return PageView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final imageUrl = data['imageUrl'] as String?;
                    final title = data['title'] as String?;
                    final route = data['route'] as String?;

                    return GestureDetector(
                      onTap: () {
                        if (route != null) {
                          Navigator.pushNamed(context, route);
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (imageUrl != null)
                            Image.network(
                              imageUrl,
                              width: 800,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          const SizedBox(height: 10),
                          if (title != null)
                            Text(
                              title,
                              style: const TextStyle(fontSize: 24),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 20), // Отступ между слайдером и квадратами

          Center(
            child: (user == null)
                ? const Text("Контент для НЕ зарегистрированных в системе")
                : const Text('Контент для ЗАРЕГИСТРИРОВАННЫХ в системе'),
          ),
          const SizedBox(height: 20), // Отступ между текстом и квадратами
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Красный квадрат для не зарегистрированных
              if (user == null)
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.red,
                ),
              const SizedBox(width: 20), // Отступ между квадратами
              // Синий квадрат только для зарегистрированных
              if (user != null)
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.blue,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
