import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // แปลงเลขบัตร + เบอร์โทร เป็น email + password สำหรับ Firebase
  String get _fakeEmail => '${_idController.text.trim()}@electric.app';
  String get _password => _phoneController.text.trim();

  Future<void> _login() async {
  if (_idController.text.trim().length != 13 || _password.isEmpty) {
    _showError('กรุณากรอกเลขบัตรประชาชน 13 หลัก และเบอร์โทรศัพท์');
    return;
  }

  setState(() => _isLoading = true);

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _fakeEmail,
      password: _password,
    );
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  } on FirebaseAuthException catch (e) {
    print('error code: ${e.code}');
    if (e.code == 'user-not-found' || 
        e.code == 'invalid-credential' ||
        e.code == 'INVALID_LOGIN_CREDENTIALS') {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _fakeEmail,
          password: _password,
        );
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e2) {
        _showError('สมัครไม่สำเร็จ: หมายเลขบัตรประชาชนนี้ถูกใช้งานแล้ว');
      }
    } else if (e.code == 'wrong-password') {
      _showError('เบอร์โทรศัพท์ไม่ถูกต้อง');
    } else {
      _showError('เกิดข้อผิดพลาด: ${e.code}');
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB8E6C8),
              Color(0xFF7EC8A4),
              Color(0xFF5BB89A),
              Color(0xFF3A9E82),
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 14),
                  const Text(
                    'ELECTRIC HOME',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: Color(0xFF1A3A2E),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildLoginCard(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logoapp.png',
      width: 110,
      height: 110,
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _idController,
            hint: 'เลขบัตรประชาชน 13 หลัก',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            maxLength: 13,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            hint: 'หมายเลขโทรศัพท์',
            icon: Icons.lock_outline,
            obscure: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: _isLoading ? null : _login,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF87), Color(0xFF2E7D5E)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF87).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'เข้าสู่ระบบ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A3A2E)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF4CAF87), size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          counterText: '',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
