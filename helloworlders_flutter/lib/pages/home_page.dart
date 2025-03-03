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
  bool isLoadingMore = false;
  bool hasMoreData = true;
  String errorMessage = '';
  final ScrollController _scrollController = ScrollController();
  int currentPage = 0;
  String? selectedCountry;
  List<String> countries = [];

  @override
  void initState() {
    super.initState();
    expatriateRepository =
        ExpatriateRepository(apiExpatriateService: ApiExpatriateService());
    fetchExpatriates();
    _scrollController.addListener(_onScroll);
    loadCountries();
  }

  Future<void> loadCountries() async {
    try {
      final response = await expatriateRepository.getAll(page: 0);
      if (response["status"] == "success") {
        Set<String> uniqueCountries = {};
        for (var expatriate in response["expatriates"]) {
          if (expatriate.country != null &&
              expatriate.country.isNotEmpty &&
              expatriate.country != "Non spécifié") {
            uniqueCountries.add(expatriate.country);
          }
        }

        setState(() {
          countries = uniqueCountries.toList()..sort();
        });
      }
    } catch (e) {}
  }

  Future<void> fetchExpatriates({bool isLoadMore = false}) async {
    if (isLoadMore && (isLoadingMore || !hasMoreData)) {
      return;
    }

    setState(() {
      if (isLoadMore) {
        isLoadingMore = true;
      } else {
        isLoading = true;
        errorMessage = '';
      }
    });

    try {
      final response = await expatriateRepository.getAll(
        isLoadMore: isLoadMore,
        page: currentPage,
        country: selectedCountry,
      );

      if (mounted) {
        setState(() {
          if (response["status"] == "success") {
            if (isLoadMore) {
              expatriates.addAll(response["expatriates"]);
              currentPage++;
            } else {
              expatriates = response["expatriates"];
              currentPage = 1;
            }
            hasMoreData = response["hasMoreData"];
          } else {
            errorMessage = response["message"];
          }
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
          errorMessage =
              "Une erreur est survenue lors de la récupération des données.";
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      fetchExpatriates(isLoadMore: true);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      currentPage = 0;
      hasMoreData = true;
      errorMessage = '';
      expatriates = [];
    });
    await fetchExpatriates();
  }

  Widget _buildContent() {
    if (isLoading && expatriates.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty && expatriates.isEmpty) {
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
      child: ListView.builder(
        controller: _scrollController,
        itemCount: expatriates.length + (hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == expatriates.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: isLoadingMore
                    ? const CircularProgressIndicator()
                    : hasMoreData
                        ? const Text('Chargement...')
                        : const Text('Plus aucun profil à charger'),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ExpatriateResume(expatriate: expatriates[index]),
          );
        },
      ),
    );
  }

  Widget _buildCountryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("Sélectionner un pays"),
                    value: selectedCountry,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text("Tous les pays"),
                      ),
                      ...countries
                          .map((country) => DropdownMenuItem<String>(
                                value: country,
                                child: Text(country),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCountry = value;
                        currentPage = 0;
                        expatriates = [];
                        hasMoreData = true;
                      });
                      fetchExpatriates();
                    },
                  ),
                ),
              ),
              if (selectedCountry != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      selectedCountry = null;
                      currentPage = 0;
                      expatriates = [];
                      hasMoreData = true;
                    });
                    fetchExpatriates();
                  },
                ),
            ],
          ),
        ],
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
                "Liste des profils",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildCountryFilter(),
            const SizedBox(height: 10),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
