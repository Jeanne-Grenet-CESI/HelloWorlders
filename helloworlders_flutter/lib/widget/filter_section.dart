import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterSection extends StatefulWidget {
  final String? selectedCountry;
  final List<String> countries;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final int resultsCount;
  final bool isLoading;
  final Function(String?) onCountryChanged;
  final VoidCallback onClearCountry;
  final Function(BuildContext, bool) onSelectDate;
  final VoidCallback onResetDateFilters;
  final VoidCallback onResetAllFilters;

  const FilterSection({
    Key? key,
    required this.selectedCountry,
    required this.countries,
    required this.filterStartDate,
    required this.filterEndDate,
    required this.resultsCount,
    required this.isLoading,
    required this.onCountryChanged,
    required this.onClearCountry,
    required this.onSelectDate,
    required this.onResetDateFilters,
    required this.onResetAllFilters,
  }) : super(key: key);

  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _contentAnimation;
  bool _isExpanded = true;
  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _isExpanded = false;
    _animationController.value = 0.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasActiveFilters =
        widget.selectedCountry != null || widget.filterStartDate != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(40),
                borderRadius: _isExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(11),
                        topRight: Radius.circular(11),
                      )
                    : BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Filtrer les profils",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  if (hasActiveFilters && _isExpanded)
                    TextButton.icon(
                      onPressed: widget.onResetAllFilters,
                      icon: Icon(
                        Icons.refresh,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      label: Text(
                        "Réinitialiser",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (hasActiveFilters && !_isExpanded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${widget.resultsCount}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _contentAnimation,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.public,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Pays",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  hint: const Text("Sélectionner un pays"),
                                  value: widget.selectedCountry,
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text("Tous les pays"),
                                    ),
                                    ...widget.countries
                                        .map((country) =>
                                            DropdownMenuItem<String>(
                                              value: country,
                                              child: Text(country),
                                            ))
                                        .toList(),
                                  ],
                                  onChanged: (value) =>
                                      widget.onCountryChanged(value),
                                ),
                              ),
                            ),
                            if (widget.selectedCountry != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: widget.onClearCountry,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.date_range,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Période de présence",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => widget.onSelectDate(context, true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.event,
                                      size: 16,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        widget.filterStartDate != null
                                            ? dateFormatter
                                                .format(widget.filterStartDate!)
                                            : "Date de début *",
                                        style: TextStyle(
                                          color: widget.filterStartDate != null
                                              ? Colors.black
                                              : Colors.grey,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.filterStartDate != null
                                  ? () => widget.onSelectDate(context, false)
                                  : () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              'Veuillez d\'abord sélectionner une date de début'),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: widget.filterStartDate != null
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.event,
                                      size: 16,
                                      color: widget.filterStartDate != null
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        widget.filterEndDate != null
                                            ? dateFormatter
                                                .format(widget.filterEndDate!)
                                            : "Date de fin",
                                        style: TextStyle(
                                          color: widget.filterEndDate != null
                                              ? Colors.black
                                              : (widget.filterStartDate != null
                                                  ? Colors.grey
                                                  : Colors.grey),
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (widget.filterStartDate != null ||
                              widget.filterEndDate != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(),
                                  onPressed: widget.onResetDateFilters,
                                  tooltip: "Effacer les dates",
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
