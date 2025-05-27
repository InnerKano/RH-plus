import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/providers/auth_provider.dart';
import 'package:rh_plus/utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  String? _errorMessage;
  Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _fieldErrors = {};
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
        _passwordConfirmController.text,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );

      if (mounted) {
        if (result['success']) {
          if (kDebugMode) {
            print('Registro exitoso, navegando al login');
          }
          
          // Mostrar mensaje de éxito y navegar al login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
          
          // Esperar un momento para que el usuario vea el mensaje
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, RouteNames.login);
            }
          });
        } else {
          if (kDebugMode) {
            print('Error en registro: ${result['message']}');
            print('Errores detallados: ${result['errors']}');
          }
          
          setState(() {
            _errorMessage = result['message'];
            
            // Procesar errores de campo específicos si existen
            if (result['errors'] != null && result['errors'] is Map) {
              final errors = result['errors'] as Map;
              errors.forEach((key, value) {
                if (value is List && value.isNotEmpty) {
                  _fieldErrors[key] = value.first.toString();
                } else if (value is String) {
                  _fieldErrors[key] = value;
                }
              });
            }
          });
        }
      }
    }
  }

  String? _getFieldError(String fieldName) {
    return _fieldErrors[fieldName];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Registro de Usuario',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: AppStrings.email,
                          prefixIcon: const Icon(Icons.email),
                          border: const OutlineInputBorder(),
                          errorText: _getFieldError('email'),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su correo electrónico';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Por favor ingrese un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                        // First name field
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: AppStrings.firstName,
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                          errorText: _getFieldError('first_name'),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      
                      // Last name field
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: AppStrings.lastName,
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                          errorText: _getFieldError('last_name'),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su apellido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: AppStrings.password,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                          errorText: _getFieldError('password'),
                        ),
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese una contraseña';
                          }
                          if (value.length < 8) {
                            return 'La contraseña debe tener al menos 8 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                        // Confirm password field
                      TextFormField(
                        controller: _passwordConfirmController,
                        decoration: InputDecoration(
                          labelText: AppStrings.confirmPassword,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordConfirmVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordConfirmVisible = !_isPasswordConfirmVisible;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                          errorText: _getFieldError('password_confirm'),
                        ),
                        obscureText: !_isPasswordConfirmVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor confirme su contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16.0),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24.0),
                      
                      // Register button
                      SizedBox(
                        width: double.infinity,
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading ? null : _register,
                          child: authProvider.isLoading
                              ? const CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                )                              : const Text(
                                  AppStrings.register,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      
                      // Login link
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, RouteNames.login);
                        },
                        child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
