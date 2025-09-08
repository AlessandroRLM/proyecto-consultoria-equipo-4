import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/ports/auth/driven/for_authenticating_user.dart';
import 'package:mobile/service_locator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppThemes.black_100 ,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage('https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png')
              ),
              const SizedBox(height: 20),
              Column(
                children: const [
                  Text(
                    'Nombre Apellido',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  SizedBox(height: 5),
                  Text(
                    'RUT: XX.XXX.XXX-X',
                    style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Año de carrera: X',
                    style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Sede: Santiago',
                      style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5),
                  ]
                ),
                const SizedBox(height: 40),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
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
                        disabledBackgroundColor: AppThemes.primary_600
                            .withValues(alpha: 0.5),
                      ),
                      child: const Text(
                        "Contactar Soporte",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppThemes.black_100,
                        ))
                    ),
                  ),
                  const SizedBox(height: 20),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                          final authService = serviceLocator<ForAuthenticatingUser>();
                          await authService.logout(); // 👈 Limpia el estado de autenticación
                          if (!mounted) return;
                          context.go('/login'); 
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sesión cerrada correctamente'),
                            backgroundColor:Colors.green,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            duration: const Duration(seconds: 3),
                            )
                            );
                        },
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        shadowColor: AppThemes.primary_600,
                        backgroundColor: AppThemes.primary_600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: AppThemes.primary_600
                            .withValues(alpha: 0.5),
                      ),
                      child: Text(
                        "Cerrar sesión",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppThemes.black_100,
                        ))
                    ),
                  ),
                  SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}