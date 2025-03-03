import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/models/expatriate.dart';
import 'package:helloworlders_flutter/models/user.dart';
import 'package:helloworlders_flutter/repositories/user_repository.dart';
import 'package:helloworlders_flutter/services/user_service.dart';
import 'package:helloworlders_flutter/widget/custom_app_bar.dart';
import 'package:helloworlders_flutter/widget/expatriate_resume.dart';
import 'package:helloworlders_flutter/widget/profile_avatar.dart';
import 'package:helloworlders_flutter/widget/info_card.dart';
import 'package:helloworlders_flutter/widget/loading_indicator.dart';
import 'package:helloworlders_flutter/widget/error_display.dart';
import 'package:helloworlders_flutter/widget/empty_state_display.dart';
import 'package:helloworlders_flutter/global/utils.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late UserRepository userRepository;
  User? user;
  List<Expatriate> userExpatriates = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    userRepository = UserRepository(apiUserService: ApiUserService());
    fetchUserAccount();
  }

  Future<void> fetchUserAccount() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await userRepository.getUserAccount();

      if (mounted) {
        setState(() {
          if (response["status"] == "success") {
            user = response["user"];
            userExpatriates = response["expatriates"];
          } else {
            errorMessage = response["message"];
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage =
              "Une erreur est survenue lors de la récupération des données.";
        });
      }
    }
  }

  Future<void> _refresh() async {
    await fetchUserAccount();
  }

  Future<void> _logout() async {
    await Global.clearToken();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vous avez été déconnecté avec succès."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return const LoadingIndicator();
    }

    if (errorMessage.isNotEmpty) {
      return ErrorDisplay(
        errorMessage: errorMessage,
        onRetry: _refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoCard(
                leading: ProfileAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  initials: user!.username,
                ),
                title: user!.username,
                subtitle: user!.email,
                trailing: user!.isAdmin
                    ? Chip(
                        label: const Text('Administrateur'),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        labelStyle: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Déconnexion'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Mes profils d'expatriés",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              if (userExpatriates.isEmpty)
                const EmptyStateDisplay(
                  message: "Vous n'avez pas encore créé de profil d'expatrié",
                  icon: Icons.person_off,
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userExpatriates.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child:
                          ExpatriateResume(expatriate: userExpatriates[index]),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Mon Compte",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}
