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

  @override
  void initState() {
    super.initState();
    expatriateRepository =
        ExpatriateRepository(apiExpatriateService: ApiExpatriateService());
    fetchExpatriates();
    _scrollController.addListener(_onScroll);
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
