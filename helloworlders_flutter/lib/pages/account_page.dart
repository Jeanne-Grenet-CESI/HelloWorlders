import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/models/expatriate.dart';
import 'package:helloworlders_flutter/models/user.dart';
import 'package:helloworlders_flutter/repositories/user_repository.dart';
import 'package:helloworlders_flutter/services/user_service.dart';
import 'package:helloworlders_flutter/widget/custom_app_bar.dart';
import 'package:helloworlders_flutter/widget/expatriate_resume.dart';

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

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('Réessayer'),
            ),
          ],
        ),
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
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Text(
                            user!.username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          user!.username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          user!.email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      if (user!.isAdmin) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: Chip(
                            label: const Text('Administrateur'),
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ],
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
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "Vous n'avez pas encore créé de profil d'expatrié",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
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
