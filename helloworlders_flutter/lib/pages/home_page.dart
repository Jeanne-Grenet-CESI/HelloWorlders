import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/repositories/expatriate_repository.dart';
import 'package:helloworlders_flutter/widget/custom_app_bar.dart';
import 'package:helloworlders_flutter/widget/expatriate_resume.dart';
import 'package:helloworlders_flutter/services/expatriate_service.dart';
import 'package:helloworlders_flutter/models/expatriate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ExpatriateRepository expatriateRepository;
  List<Expatriate> expatriates = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    expatriateRepository =
        ExpatriateRepository(apiExpatriateService: ApiExpatriateService());
    fetchExpatriates();
  }

  Future<void> fetchExpatriates() async {
    try {
      final response = await expatriateRepository.getAll();
      if (mounted) {
        setState(() {
          isLoading = false;
          if (response["status"] == "success") {
            expatriates = response["expatriates"];
          } else {
            errorMessage = response["message"];
          }
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
                "Liste des profils",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Center(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: expatriates.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ExpatriateResume(expatriate: expatriates[index]),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
