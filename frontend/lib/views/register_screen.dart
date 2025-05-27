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
  
  // Nuevos controladores para campos de empresa
  final _companyNameController = TextEditingController();
  final _companyTaxIdController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _companyWebsiteController = TextEditingController();
  
  // Variable para tipo de registro seleccionado
  String _registerType = 'no_company'; // Valor por defecto
  
  // Variable para ID de empresa si elige unirse a una
  int? _selectedCompanyId;
  
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
    // Dispose de los nuevos controladores
    _companyNameController.dispose();
    _companyTaxIdController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    _companyEmailController.dispose();
    _companyWebsiteController.dispose();
    super.dispose();
  }
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _fieldErrors = {};
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Preparar argumentos según el tipo de registro
      Map<String, dynamic> extraArgs = {};
      
      if (_registerType == 'new_company') {
        extraArgs = {
          'companyName': _companyNameController.text.trim(),
          'companyTaxId': _companyTaxIdController.text.trim(),
          'companyAddress': _companyAddressController.text.trim(),
          'companyPhone': _companyPhoneController.text.trim(),
          'companyEmail': _companyEmailController.text.trim(),
          'companyWebsite': _companyWebsiteController.text.trim(),
        };
      } else if (_registerType == 'join_company') {
        extraArgs = {
          'companyId': _selectedCompanyId,
        };
      }
      
      final result = await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
        _passwordConfirmController.text,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _registerType,
        companyName: extraArgs['companyName'],
        companyTaxId: extraArgs['companyTaxId'],
        companyAddress: extraArgs['companyAddress'],
        companyPhone: extraArgs['companyPhone'],
        companyEmail: extraArgs['companyEmail'],
        companyWebsite: extraArgs['companyWebsite'],
        companyId: extraArgs['companyId'],
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
                      
                      const SizedBox(height: 16.0),
                      
                      // Divider con texto para sección de empresa
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('Información de Empresa', 
                              style: TextStyle(color: Colors.grey)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      
                      const SizedBox(height: 16.0),
                      
                      // Selector de tipo de registro
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tipo de Registro:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                          RadioListTile<String>(
                            title: const Text('Usuario Individual'),
                            value: 'no_company',
                            groupValue: _registerType,
                            onChanged: (value) {
                              setState(() {
                                _registerType = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Crear Nueva Empresa'),
                            value: 'new_company',
                            groupValue: _registerType,
                            onChanged: (value) {
                              setState(() {
                                _registerType = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Unirse a Empresa Existente'),
                            value: 'join_company',
                            groupValue: _registerType,
                            onChanged: (value) {
                              setState(() {
                                _registerType = value!;
                              });
                            },
                          ),
                          if (_getFieldError('register_type') != null)
                            Text(
                              _getFieldError('register_type')!,
                              style: const TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 16.0),
                      
                      // Campos condicionales según el tipo de registro
                      if (_registerType == 'new_company') ...[
                        // Campos para nueva empresa
                        TextFormField(
                          controller: _companyNameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre de la Empresa',
                            prefixIcon: const Icon(Icons.business),
                            border: const OutlineInputBorder(),
                            errorText: _getFieldError('company_name'),
                          ),
                          validator: (value) {
                            if (_registerType == 'new_company' && (value == null || value.isEmpty)) {
                              return 'Por favor ingrese el nombre de la empresa';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _companyTaxIdController,
                          decoration: InputDecoration(
                            labelText: 'ID Fiscal / RFC',
                            prefixIcon: const Icon(Icons.numbers),
                            border: const OutlineInputBorder(),
                            errorText: _getFieldError('company_tax_id'),
                          ),
                          validator: (value) {
                            if (_registerType == 'new_company' && (value == null || value.isEmpty)) {
                              return 'Por favor ingrese el ID fiscal de la empresa';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _companyAddressController,
                          decoration: InputDecoration(
                            labelText: 'Dirección',
                            prefixIcon: const Icon(Icons.location_on),
                            border: const OutlineInputBorder(),
                            errorText: _getFieldError('company_address'),
                          ),
                          validator: (value) {
                            if (_registerType == 'new_company' && (value == null || value.isEmpty)) {
                              return 'Por favor ingrese la dirección de la empresa';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _companyPhoneController,
                          decoration: InputDecoration(
                            labelText: 'Teléfono',
                            prefixIcon: const Icon(Icons.phone),
                            border: const OutlineInputBorder(),
                            errorText: _getFieldError('company_phone'),
                          ),
                          validator: (value) {
                            if (_registerType == 'new_company' && (value == null || value.isEmpty)) {
                              return 'Por favor ingrese el teléfono de la empresa';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _companyEmailController,
                          decoration: InputDecoration(
                            labelText: 'Email de la Empresa (opcional)',
                            prefixIcon: const Icon(Icons.email),
                            border: const OutlineInputBorder(),
                            errorText: _getFieldError('company_email'),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _companyWebsiteController,
                          decoration: InputDecoration(
                            labelText: 'Sitio Web (opcional)',
                            prefixIcon: const Icon(Icons.web),
                            border: const OutlineInputBorder(),
                            errorText: _getFieldError('company_website'),
                          ),
                          keyboardType: TextInputType.url,
                        ),
                      ] else if (_registerType == 'join_company') ...[
                        // Por ahora un campo simple para ID de empresa
                        // En una implementación real, aquí iría un dropdown o una búsqueda
                        // que permita seleccionar la empresa de una lista
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'ID de la Empresa',
                            prefixIcon: const Icon(Icons.business),
                            border: const OutlineInputBorder(),
                            errorText: _getFieldError('company_id'),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_registerType == 'join_company') {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese el ID de la empresa';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Por favor ingrese un número válido';
                              }
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (int.tryParse(value) != null) {
                              _selectedCompanyId = int.parse(value);
                            }
                          },
                        ),
                      ],
                      
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
