import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/repositories/expatriate_repository.dart';
import 'package:helloworlders_flutter/widget/custom_app_bar.dart';
import 'package:helloworlders_flutter/widget/expatriate_resume.dart';
import 'package:helloworlders_flutter/services/expatriate_service.dart';
import 'package:helloworlders_flutter/models/expatriate.dart';
import 'package:intl/intl.dart';

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

  DateTime? filterStartDate;
  DateTime? filterEndDate;
  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

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
      DateTime? endDateParam = filterEndDate;
      if (filterStartDate == null) {
        endDateParam = null;
      }

      final response = await expatriateRepository.getAll(
        isLoadMore: isLoadMore,
        page: currentPage,
        country: selectedCountry,
        startDate: filterStartDate,
        endDate: endDateParam,
      );

      if (mounted) {
        setState(() {
          if (response["status"] == "success") {
            final List<Expatriate> fetchedExpatriates =
                response["expatriates"] != null
                    ? List<Expatriate>.from(response["expatriates"])
                    : [];

            if (isLoadMore) {
              if (fetchedExpatriates.isNotEmpty) {
                expatriates.addAll(fetchedExpatriates);
              }
              currentPage++;
            } else {
              expatriates = fetchedExpatriates;
              currentPage = 1;
            }

            hasMoreData = response["hasMoreData"] ?? false;
            errorMessage = '';
          } else {
            errorMessage = response["message"] ?? "Erreur inconnue";
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

  // Méthode pour réinitialiser tous les filtres
  void _resetAllFilters() {
    setState(() {
      selectedCountry = null;
      filterStartDate = null;
      filterEndDate = null;
      currentPage = 0;
      hasMoreData = true;
      errorMessage = '';
      expatriates = [];
    });
    fetchExpatriates();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate;
    DateTime firstDate;

    if (isStartDate) {
      initialDate = filterStartDate ?? DateTime.now();
      firstDate = DateTime(2000);
    } else {
      if (filterStartDate != null) {
        initialDate = filterEndDate ?? filterStartDate!;
        firstDate = filterStartDate!;
      } else {
        initialDate = filterEndDate ?? DateTime.now();
        firstDate = DateTime(2000);
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          filterStartDate = picked;
          if (filterEndDate != null && filterEndDate!.isBefore(picked)) {
            filterEndDate = null;
          }
        } else {
          filterEndDate = picked;
        }
        currentPage = 0;
        expatriates = [];
        hasMoreData = true;
      });
      fetchExpatriates();
    }
  }

  void _resetDateFilters() {
    setState(() {
      filterStartDate = null;
      filterEndDate = null;
      currentPage = 0;
      expatriates = [];
      hasMoreData = true;
    });
    fetchExpatriates();
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

    if (expatriates.isEmpty &&
        (selectedCountry != null || filterStartDate != null)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Aucun profil ne correspond aux critères sélectionnés",
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetAllFilters,
              child: const Text('Réinitialiser les filtres'),
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

  Widget _buildDateFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Période de présence :",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context, true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            filterStartDate != null
                                ? dateFormatter.format(filterStartDate!)
                                : "Date de début *",
                            style: TextStyle(
                              color: filterStartDate != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: filterStartDate != null
                      ? () => _selectDate(context, false)
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Veuillez d\'abord sélectionner une date de début'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: filterStartDate != null
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 16,
                          color: filterStartDate != null
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            filterEndDate != null
                                ? dateFormatter.format(filterEndDate!)
                                : "Date de fin",
                            style: TextStyle(
                              color: filterEndDate != null
                                  ? Colors.black
                                  : (filterStartDate != null
                                      ? Colors.grey
                                      : Colors.grey),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (filterStartDate != null || filterEndDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _resetDateFilters,
                  tooltip: "Effacer les filtres de dates",
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
            _buildDateFilters(),
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
