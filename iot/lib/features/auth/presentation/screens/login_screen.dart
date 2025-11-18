import 'package:flutter/material.dart';
import 'package:iot/core/core.dart';
import '../providers/auth_notifier.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _deviceIdController = TextEditingController();
  final _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isTokenVisible = false;

  @override
  void dispose() {
    _deviceIdController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
<<<<<<< Updated upstream
    
=======

>>>>>>> Stashed changes
    return Scaffold(
      backgroundColor: SHColors.backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
<<<<<<< Updated upstream
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom - 48,
=======
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  48,
>>>>>>> Stashed changes
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeader(),
                        SizedBox(height: isKeyboardVisible ? 24 : 48),
                        _buildLoginForm(),
                        SizedBox(height: isKeyboardVisible ? 16 : 24),
                        _buildLoginButton(),
                      ],
                    ),
                  ),
                  if (!isKeyboardVisible) _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;
<<<<<<< Updated upstream
    
=======

>>>>>>> Stashed changes
    return Column(
      children: [
        Container(
          width: isKeyboardVisible ? 80 : 120,
          height: isKeyboardVisible ? 80 : 120,
          decoration: BoxDecoration(
            color: SHColors.selectedColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.sensors,
            size: isKeyboardVisible ? 40 : 60,
            color: SHColors.selectedColor,
          ),
        ),
        SizedBox(height: isKeyboardVisible ? 16 : 24),
        Text(
          'IoT Microgrid',
          style: TextStyle(
            color: Colors.white,
            fontSize: isKeyboardVisible ? 28 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isKeyboardVisible ? 4 : 8),
        Text(
          'Accede con tus credenciales del dispositivo',
          style: TextStyle(
<<<<<<< Updated upstream
            color: Colors.white.withOpacity(0.7), 
            fontSize: isKeyboardVisible ? 14 : 16
=======
            color: Colors.white.withOpacity(0.7),
            fontSize: isKeyboardVisible ? 14 : 16,
>>>>>>> Stashed changes
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildDeviceIdField(),
          const SizedBox(height: 20),
          _buildTokenField(),
        ],
      ),
    );
  }

  Widget _buildDeviceIdField() {
    return TextFormField(
      controller: _deviceIdController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Device ID',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        hintText: 'ej: dev-001, microgrid-central',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: const Icon(
          Icons.developer_board,
          color: SHColors.selectedColor,
        ),
        filled: true,
        fillColor: SHColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SHColors.selectedColor, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El Device ID es requerido';
        }
        return null;
      },
    );
  }

  Widget _buildTokenField() {
    return TextFormField(
      controller: _tokenController,
      style: const TextStyle(color: Colors.white),
      obscureText: !_isTokenVisible,
      decoration: InputDecoration(
        labelText: 'InfluxDB Token',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        hintText: 'Token de acceso a InfluxDB',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: const Icon(Icons.vpn_key, color: SHColors.selectedColor),
        suffixIcon: IconButton(
          icon: Icon(
            _isTokenVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white.withOpacity(0.7),
          ),
          onPressed: () {
            setState(() {
              _isTokenVisible = !_isTokenVisible;
            });
          },
        ),
        filled: true,
        fillColor: SHColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SHColors.selectedColor, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El token de InfluxDB es requerido';
        }
        if (value.length < 20) {
          return 'El token parece ser muy corto';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return ValueListenableBuilder<AuthState>(
      valueListenable: AuthProvider.of(context)!,
      builder: (context, authState, _) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: authState.status == AuthStatus.loading
                ? null
                : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: SHColors.selectedColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: authState.status == AuthStatus.loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Asegúrate de tener acceso a InfluxDB',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          'Versión 1.0.0',
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
        ),
      ],
    );
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = AuthProvider.of(context)!;
    authNotifier.login(
      _deviceIdController.text.trim(),
      _tokenController.text.trim(),
    );
  }
}

// Provider para AuthNotifier
class AuthProvider extends InheritedNotifier<AuthNotifier> {
  const AuthProvider({
    super.key,
    required AuthNotifier super.notifier,
    required super.child,
  });

  static AuthNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthProvider>()?.notifier;
  }
}
