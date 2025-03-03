import 'package:flutter/material.dart';
import 'package:helloworlders_flutter/repositories/expatriate_repository.dart';
import 'package:helloworlders_flutter/widget/custom_app_bar.dart';
import 'package:helloworlders_flutter/widget/expatriate_resume.dart';
import 'package:helloworlders_flutter/widget/filter_section.dart';
import 'package:helloworlders_flutter/widget/loading_indicator.dart';
import 'package:helloworlders_flutter/widget/error_display.dart';
import 'package:helloworlders_flutter/widget/empty_state_display.dart';
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
    } catch (e) {
      // Ne rien faire en cas d'erreur
    }
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

  void _handleCountryChanged(String? value) {
    setState(() {
      selectedCountry = value;
      currentPage = 0;
      expatriates = [];
      hasMoreData = true;
    });
    fetchExpatriates();
  }

  void _handleClearCountry() {
    setState(() {
      selectedCountry = null;
      currentPage = 0;
      expatriates = [];
      hasMoreData = true;
    });
    fetchExpatriates();
  }

  void _handleDateSelected(DateTime date, bool isStartDate) {
    setState(() {
      if (isStartDate) {
        filterStartDate = date;
        if (filterEndDate != null && filterEndDate!.isBefore(date)) {
          filterEndDate = null;
        }
      } else {
        filterEndDate = date;
      }
      currentPage = 0;
      expatriates = [];
      hasMoreData = true;
    });
    fetchExpatriates();
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
      return const LoadingIndicator();
    }

    if (errorMessage.isNotEmpty && expatriates.isEmpty) {
      return ErrorDisplay(
        errorMessage: errorMessage,
        onRetry: _refresh,
      );
    }

    if (expatriates.isEmpty &&
        (selectedCountry != null || filterStartDate != null)) {
      return EmptyStateDisplay(
        message: "Aucun profil ne correspond aux critères sélectionnés",
        icon: Icons.search_off,
        actionButtonText: 'Réinitialiser les filtres',
        onActionPressed: _resetAllFilters,
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
                    ? const LoadingIndicator(size: 24, strokeWidth: 2)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
            FilterSection(
              selectedCountry: selectedCountry,
              countries: countries,
              filterStartDate: filterStartDate,
              filterEndDate: filterEndDate,
              resultsCount: expatriates.length,
              isLoading: isLoading,
              onCountryChanged: _handleCountryChanged,
              onClearCountry: _handleClearCountry,
              onSelectDate: (context, isStartDate) async {
                final DateTime now = DateTime.now();
                final DateTime initialDate = isStartDate
                    ? (filterStartDate ?? now)
                    : (filterEndDate ?? now);
                final DateTime firstDate = isStartDate
                    ? DateTime(2000)
                    : (filterStartDate ?? DateTime(2000));

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
                  _handleDateSelected(picked, isStartDate);
                }
              },
              onResetDateFilters: _resetDateFilters,
              onResetAllFilters: _resetAllFilters,
            ),
            const SizedBox(height: 16),
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
