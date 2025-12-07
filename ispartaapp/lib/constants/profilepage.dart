import 'package:flutter/material.dart';
import 'package:ispartaapp/services/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isUser = false;
  @override
  Widget build(BuildContext context) {
    return isUser
        ? Scaffold(body: Column(children: [Text("data")]))
        : AuthPage();
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: null,
            decoration: InputDecoration(hintText: "İsim"),
          ),
          TextField(
            controller: null,
            decoration: InputDecoration(hintText: "Soyisim"),
          ),
          TextField(
            controller: null,
            decoration: InputDecoration(hintText: "E-posta adresiniz"),
          ),
          TextField(
            controller: null,
            decoration: InputDecoration(hintText: "şifre"),
          ),
          Row(
            children: [
              Expanded(child: Divider(thickness: 0.5)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text("Veya"),
              ),
              Expanded(child: Divider(thickness: 0.5)),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  // Image.asset()
                  Expanded(child: Text("Google ile giriş yap")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
