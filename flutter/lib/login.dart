import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return Center(
            child: isWide
                ? Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Image.asset(
                          'assets/images/loginphoto.png',
                          fit: BoxFit.cover,
                          height: double.infinity,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildForm(),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Image.asset(
                          'assets/loginlogo.png',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildForm(),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 292,
            height: 43,
            child: TextField(
              // controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 292,
            height: 43,
            child: TextField(
              // controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
              ),
              obscureText: true,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 292,
            height: 43,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5576F5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: null,
              child: const Text('Login', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
