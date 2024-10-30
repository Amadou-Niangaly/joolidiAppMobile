import 'package:bs_app_mobile/iu/pages/edit_profil.dart';
import 'package:bs_app_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';

class ProfPage extends StatefulWidget {
  const ProfPage({super.key});

  @override
  _ProfPageState createState() => _ProfPageState();
}

class _ProfPageState extends State<ProfPage> {
  final FirebaseAuthService authService = FirebaseAuthService();
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final info = await authService.getUserInfo();
    setState(() {
      userInfo = info;
    });
  }

  Future<void> _logout() async {
    await authService.signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Expanded(flex: 2, child: _TopPortion()),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: userInfo == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${userInfo!['nom']} ${userInfo!['prenom']}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              onPressed: () {
                                // Naviguer vers la page d'édition de profil
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfilPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          context,
                          Icons.email,
                          "Email",
                          userInfo!['email'],
                        ),
                        _buildInfoRow(
                          context,
                          Icons.phone,
                          "Téléphone",
                          userInfo!['numeroTelephone'],
                        ),
                        _buildInfoRow(
                          context,
                          Icons.cake,
                          "Date de naissance",
                          userInfo!['dateNaissance'],
                        ),
                        _buildInfoRow(
                          context,
                          Icons.bloodtype,
                          "Groupe sanguin",
                          userInfo!['groupeSanguin'],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_sharp, color: Color(0xFFFFFFFF)),
                          label: const Text(
                            "Deconnexion",
                            style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700], size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _TopPortion extends StatelessWidget {
  const _TopPortion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFFD80032), Color(0xFFD80032)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/default.png')
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


