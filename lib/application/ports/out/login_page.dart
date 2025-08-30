import 'package:flutter/material.dart';
import 'package:mobile/adapter/core/out/app_themes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppThemes.black_100,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Inicia sesión',
                    style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppThemes.primary_600)),
                SizedBox(height: 10),
                Text('¡Que bueno tenerte de vuelta!',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppThemes.black_1300)),
                SizedBox(height: 50),
                TextField(
                    decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: TextStyle(color: AppThemes.black_800,fontSize: 14),
                        filled: true,
                        fillColor: AppThemes.primary_100,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppThemes.primary_600)
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppThemes.primary_100), // aquí cambias el color
                            ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppThemes.primary_600,width: 2)
                        )
                    )
                ),
                const SizedBox(height: 20),
                TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  labelStyle: const TextStyle(color: AppThemes.black_800,fontSize: 14),
                  filled: true,
                  fillColor: AppThemes.primary_100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppThemes.primary_100), // aquí cambias el color
                ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppThemes.primary_600, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(color: AppThemes.primary_600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
               SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shadowColor: AppThemes.primary_600,
                    backgroundColor: AppThemes.primary_600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Iniciar sesión",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppThemes.black_100,
                    ))))
              ]
            ),
          ),
        ),
      ),
    );
  }
}