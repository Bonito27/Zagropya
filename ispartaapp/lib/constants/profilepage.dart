import 'package:flutter/material.dart';
import 'package:ispartaapp/services/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Kullanıcının giriş yapıp yapmadığını tutan değişken (İleride Firebase'den gelecek)
  bool isUserLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    // Eğer kullanıcı giriş yaptıysa Profil içeriği, yapmadıysa Auth sayfası göster
    return isUserLoggedIn
        ? Scaffold(body: Center(child: Text("Kullanıcı Profili Burada Olacak")))
        : const AuthPage();
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // true = Giriş Ekranı, false = Kayıt Ekranı
  bool isLoginMode = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- BAŞLIK ---
                Text(
                  isLoginMode ? "Giriş Yap" : "Kayıt Ol",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary, // Senin renk dosyan
                  ),
                ),
                const SizedBox(height: 30),

                // --- SADECE KAYIT OL MODUNDA GÖZÜKECEK ALANLAR ---
                if (!isLoginMode) ...[
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration("İsim", Icons.person),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _surnameController,
                    decoration: _inputDecoration(
                      "Soyisim",
                      Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // --- ORTAK ALANLAR (Email & Şifre) ---
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration(
                    "E-posta adresiniz",
                    Icons.email_outlined,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Şifreyi gizler
                  decoration: _inputDecoration("Şifre", Icons.lock_outline),
                ),

                const SizedBox(height: 20),

                // --- ANA BUTON (Giriş Yap / Kayıt Ol) ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Buraya Firebase giriş/kayıt fonksiyonları gelecek
                      print(
                        isLoginMode
                            ? "Giriş yapılıyor..."
                            : "Kayıt olunuyor...",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isLoginMode ? "Giriş Yap" : "Kayıt Ol",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: const [
                    Expanded(child: Divider(thickness: 0.5)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Veya", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(thickness: 0.5)),
                  ],
                ),

                const SizedBox(height: 20),

                // --- GOOGLE GİRİŞ BUTONU ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 1,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        //  buraya Google logosu
                        SizedBox(width: 10),
                        Text(
                          "Google ile giriş yap",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- EKRAN DEĞİŞTİRME (Login <-> Register) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLoginMode
                          ? "Hesabın yok mu? "
                          : "Zaten hesabın var mı? ",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isLoginMode = !isLoginMode; // Modu tersine çevir
                        });
                      },
                      child: Text(
                        isLoginMode ? "Kayıt Ol" : "Giriş Yap",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Kod tekrarını önlemek için input şablon halinde
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
