import 'package:brasserie_mob/pages/login_page.dart';
import 'package:brasserie_mob/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? userName;
  final VoidCallback? onLogout;

  const Header({
    super.key,
    required this.title,
    this.userName,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF8B4513),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'lib/images/brasserie_logo.png',
          height: 40,
          width: 40,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: userName != null
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Text(
                    'Bienvenue, $userName',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: onLogout ??
                    () {
                      // Par défaut, rien si pas défini
                    },
              ),
            ]
          : [
              IconButton(
                icon: const Icon(Icons.login),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.app_registration),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
              ),
            ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
