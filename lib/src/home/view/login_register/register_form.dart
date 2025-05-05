import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loveradar/src/home/controller/users_bloc/users_bloc.dart';
import 'package:loveradar/src/home/model/users_model.dart';
import 'package:loveradar/src/home/view/login_register/auth.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class RegisterFormScreen extends StatefulWidget {
  const RegisterFormScreen({super.key});

  @override
  State<RegisterFormScreen> createState() => _RegisterFormScreenState();
}

class _RegisterFormScreenState extends State<RegisterFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();
  final TextEditingController _edadController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  String? errorMessage = "";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _fechaNacimientoController.text =
            DateFormat('dd-MM-yyyy').format(picked);
        _edadController.text = _calcularEdad(picked).toString();
      });
    }
  }

  int _calcularEdad(DateTime fechaNacimiento) {
    final hoy = DateTime.now();
    int edad = hoy.year - fechaNacimiento.year;
    if (hoy.month < fechaNacimiento.month ||
        (hoy.month == fechaNacimiento.month && hoy.day < fechaNacimiento.day)) {
      edad--;
    }
    return edad;
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      // Aquí puedes manejar el registro

      try {
        await Auth().createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage!)),
          );
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );
      Users userInfo = Users(
          email: _emailController.text,
          name: _nombreController.text,
          lastName: _apellidoController.text,
          age: _edadController.text,
          birthDate: _fechaNacimientoController.text,
          gender: _selectedGender);

      BlocProvider.of<UsersBloc>(context).add(AddUserEvent(userInfo));
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fechaNacimientoController.dispose();
    _edadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        if (state is UsersLoading) {
          return Center(
              child: Shimmer(
            child: Container(
              color: Colors.deepPurple,
            ),
          ));
        } else if (state is UsersLoaded) {
          return Scaffold(
              body: Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: Text("Ir al inicio"),
            ),
          ));
        } else if (state is UsersInitial) {
          return _buildBody();
        } else if (state is UsersError) {
          return _buildBody();
        } else {
          return _buildBody();
        }
      },
    );
  }

  Widget _buildBody() {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : 'Campo obligatorio',
              ),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : 'Campo obligatorio',
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  if (!value.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  if (value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Confirmar Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obligatorio';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fechaNacimientoController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha de nacimiento',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : 'Campo obligatorio',
              ),
              TextFormField(
                controller: _edadController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Edad'),
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : 'Campo obligatorio',
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Sexo'),
                items: const [
                  DropdownMenuItem(
                      value: 'Masculino', child: Text('Masculino')),
                  DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) =>
                    value != null ? null : 'Campo obligatorio',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
