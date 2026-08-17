import 'package:flutter/material.dart';

enum SortOption {
  none('No Sorting'),
  newest('Newest First'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  popularity('Most Popular'),
  ratingHighToLow('Highest Rated'),
  alphabeticalAZ('A to Z'),
  alphabeticalZA('Z to A');

  const SortOption(this.displayName);
  final String displayName;
}

enum FilterType {
  priceRange,
  availability,
  rating,
  brand,
  size,
  color,
  category,
  discount
}

class FilterCriteria {
  RangeValues? priceRange;
  double? minRating;
  List<String>? selectedBrands;
  List<String>? selectedSizes;
  List<String>? selectedColors;
  List<String>? selectedCategories;

  FilterCriteria({
    this.priceRange,
    this.minRating,
    this.selectedBrands,
    this.selectedSizes,
    this.selectedColors,
    this.selectedCategories,
  });

  FilterCriteria copyWith({
    RangeValues? priceRange,
    double? minRating,
    List<String>? selectedBrands,
    List<String>? selectedSizes,
    List<String>? selectedColors,
    List<String>? selectedCategories,
  }) {
    return FilterCriteria(
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
      selectedBrands: selectedBrands ?? this.selectedBrands,
      selectedSizes: selectedSizes ?? this.selectedSizes,
      selectedColors: selectedColors ?? this.selectedColors,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }

  bool get hasActiveFilters {
    return (priceRange != null && priceRange!.start > 0) ||
           (minRating != null && minRating! > 0) ||
           (selectedBrands?.isNotEmpty == true) ||
           (selectedSizes?.isNotEmpty == true) ||
           (selectedColors?.isNotEmpty == true) ||
           (selectedCategories?.isNotEmpty == true);
  }

  void clearAll() {
    priceRange = null;
    minRating = null;
    selectedBrands = null;
    selectedSizes = null;
    selectedColors = null;
    selectedCategories = null;
  }
}

class AdvancedFilterWidget extends StatefulWidget {
  final FilterCriteria currentFilters;
  final SortOption currentSort;
  final Function(FilterCriteria) onFiltersChanged;
  final Function(SortOption) onSortChanged;
  final Function() onFiltersCleared;
  final double minPrice;
  final double maxPrice;
  final List<String> availableBrands;
  final List<String> availableSizes;
  final List<String> availableColors;
  final List<String> availableCategories;

  const AdvancedFilterWidget({
    Key? key,
    required this.currentFilters,
    required this.currentSort,
    required this.onFiltersChanged,
    required this.onSortChanged,
    required this.onFiltersCleared,
    required this.minPrice,
    required this.maxPrice,
    required this.availableBrands,
    required this.availableSizes,
    required this.availableColors,
    required this.availableCategories,
  }) : super(key: key);

  @override
  _AdvancedFilterWidgetState createState() => _AdvancedFilterWidgetState();
}

class _AdvancedFilterWidgetState extends State<AdvancedFilterWidget> {
  late FilterCriteria _tempFilters;
  late SortOption _tempSort;
  bool _showAdvancedFilters = false;

  @override
  void initState() {
    super.initState();
    _tempFilters = widget.currentFilters;
    _tempSort = widget.currentSort;
  }

  @override
  void didUpdateWidget(AdvancedFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentFilters != widget.currentFilters ||
        oldWidget.currentSort != widget.currentSort) {
      _tempFilters = widget.currentFilters;
      _tempSort = widget.currentSort;
    }
  }

  void _updateFilters(FilterCriteria newFilters) {
    setState(() {
      _tempFilters = newFilters;
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_tempFilters);
    widget.onSortChanged(_tempSort);
    Navigator.of(context).pop();
  }

  void _clearAllFilters() {
    setState(() {
      _tempFilters.clearAll();
      _tempSort = SortOption.none;
    });
    widget.onFiltersCleared();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters & Sort',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(111, 10, 15, 1),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    foregroundColor: const Color.fromRGBO(111, 10, 15, 1),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  _buildSortSection(),
                  const Divider(),
                  _buildQuickFilters(),
                  ListTile(
                    title: const Text(
                      'Advanced Filters',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Icon(
                      _showAdvancedFilters
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                    onTap: () {
                      setState(() {
                        _showAdvancedFilters = !_showAdvancedFilters;
                      });
                    },
                  ),
                  if (_showAdvancedFilters) ...[
                    const Divider(),
                    _buildPriceRangeFilter(),
                    const SizedBox(height: 16),
                    _buildRatingFilter(),
                    const SizedBox(height: 16),
                    _buildBrandFilter(),
                    const SizedBox(height: 16),
                    _buildSizeFilter(),
                    const SizedBox(height: 16),
                    _buildColorFilter(),
                    const SizedBox(height: 16),
                    _buildCategoryFilter(),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearAllFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color.fromRGBO(111, 10, 15, 1)),
                    ),
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: Color.fromRGBO(111, 10, 15, 1)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort By',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SortOption.values.map((sortOption) {
            final isSelected = _tempSort == sortOption;
            return FilterChip(
              label: Text(sortOption.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _tempSort = sortOption;
                  });
                }
              },
              backgroundColor: Colors.grey[100],
              selectedColor: const Color.fromRGBO(111, 10, 15, 0.1),
              checkmarkColor: const Color.fromRGBO(111, 10, 15, 1),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Filters',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('4+ Stars'),
              selected: _tempFilters.minRating == 4.0,
              onSelected: (selected) {
                _updateFilters(_tempFilters.copyWith(
                  minRating: selected ? 4.0 : null,
                ));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    final currentRange = _tempFilters.priceRange ??
        RangeValues(widget.minPrice, widget.maxPrice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: currentRange,
          min: widget.minPrice,
          max: widget.maxPrice,
          divisions: 50,
          activeColor: const Color.fromRGBO(111, 10, 15, 1),
          labels: RangeLabels(
            '₹${currentRange.start.round()}',
            '₹${currentRange.end.round()}',
          ),
          onChanged: (RangeValues values) {
            _updateFilters(_tempFilters.copyWith(priceRange: values));
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('₹${widget.minPrice.round()}'),
            Text('₹${widget.maxPrice.round()}'),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum Rating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [0.0, 2.0, 3.0, 4.0, 4.5].map((rating) {
            final isSelected = _tempFilters.minRating == rating;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$rating'),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  if (rating > 0) const Text('+'),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                _updateFilters(_tempFilters.copyWith(
                  minRating: selected ? rating : null,
                ));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBrandFilter() {
    if (widget.availableBrands.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Brands',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableBrands.map((brand) {
            final isSelected = _tempFilters.selectedBrands?.contains(brand) ?? false;
            return FilterChip(
              label: Text(brand),
              selected: isSelected,
              onSelected: (selected) {
                final currentBrands = _tempFilters.selectedBrands ?? [];
                final newBrands = selected
                    ? [...currentBrands, brand]
                    : currentBrands.where((b) => b != brand).toList();
                _updateFilters(_tempFilters.copyWith(
                  selectedBrands: newBrands.isEmpty ? null : newBrands,
                ));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeFilter() {
    if (widget.availableSizes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Variant',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableSizes.map((size) {
            final isSelected = _tempFilters.selectedSizes?.contains(size) ?? false;
            return FilterChip(
              label: Text(size),
              selected: isSelected,
              onSelected: (selected) {
                final currentSizes = _tempFilters.selectedSizes ?? [];
                final newSizes = selected
                    ? [...currentSizes, size]
                    : currentSizes.where((s) => s != size).toList();
                _updateFilters(_tempFilters.copyWith(
                  selectedSizes: newSizes.isEmpty ? null : newSizes,
                ));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorFilter() {
    if (widget.availableColors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableColors.map((color) {
            final isSelected = _tempFilters.selectedColors?.contains(color) ?? false;
            return FilterChip(
              label: Text(color),
              selected: isSelected,
              onSelected: (selected) {
                final currentColors = _tempFilters.selectedColors ?? [];
                final newColors = selected
                    ? [...currentColors, color]
                    : currentColors.where((c) => c != color).toList();
                _updateFilters(_tempFilters.copyWith(
                  selectedColors: newColors.isEmpty ? null : newColors,
                ));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    if (widget.availableCategories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableCategories.map((category) {
            final isSelected = _tempFilters.selectedCategories?.contains(category) ?? false;
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                final currentCategories = _tempFilters.selectedCategories ?? [];
                final newCategories = selected
                    ? [...currentCategories, category]
                    : currentCategories.where((c) => c != category).toList();
                _updateFilters(_tempFilters.copyWith(
                  selectedCategories: newCategories.isEmpty ? null : newCategories,
                ));
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
