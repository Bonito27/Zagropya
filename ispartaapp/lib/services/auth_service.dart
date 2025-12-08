import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // --- KAYIT OL (Register) ---
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) async {
    try {
      // 1. Kullanıcıyı oluştur
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. İsim ve Soyisimi "DisplayName" olarak kaydet (İleride profil için lazım olur)
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName("$name $surname");
        await userCredential.user!.reload(); // Bilgileri yenile
      }

      return "success"; // Başarılı
    } on FirebaseAuthException catch (e) {
      // Hata kodlarını Türkçeleştir
      switch (e.code) {
        case "email-already-in-use":
          return "Bu e-posta zaten kullanımda.";
        case "invalid-email":
          return "Geçersiz e-posta adresi.";
        case "weak-password":
          return "Şifre çok zayıf (En az 6 karakter).";
        default:
          return "Bir hata oluştu: ${e.message}";
      }
    }
  }

  // --- GİRİŞ YAP (Login) ---
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "success";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          return "Kullanıcı bulunamadı.";
        case "wrong-password":
          return "Hatalı şifre.";
        default:
          return "Giriş başarısız: ${e.message}";
      }
    }
  }

  // --- ÇIKIŞ YAP ---
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
