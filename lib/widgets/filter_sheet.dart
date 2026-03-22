import 'package:flutter/material.dart';
import 'package:collabhub/utils/constants.dart';

/// Slide-in filter panel matching the Figma spec.
class FilterSheet extends StatefulWidget {
  final String initialStatus;
  final String initialSortBy;
  final void Function(String status, String sortBy) onApply;

  const FilterSheet({
    super.key,
    required this.initialStatus,
    required this.initialSortBy,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String _status;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _sortBy = widget.initialSortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      constraints: const BoxConstraints(maxWidth: 384),
      height: double.infinity,
      color: AppColors.surface(context),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Divider(height: 1, color: AppColors.border(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildSection(
                      context: context,
                      title: 'Status',
                      options: const [
                        ('all', 'All Projects'),
                        ('open', 'Open Only'),
                        ('closed', 'Closed Only'),
                      ],
                      selected: _status,
                      onChanged: (v) => setState(() => _status = v),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context: context,
                      title: 'Sort By',
                      options: const [
                        ('recent', 'Most Recent'),
                        ('upvoted', 'Most Upvoted'),
                        ('downvoted', 'Most Downvoted'),
                      ],
                      selected: _sortBy,
                      onChanged: (v) => setState(() => _sortBy = v),
                    ),
                    const SizedBox(height: 32),
                    _buildResetButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter & Sort',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface(context),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Customize how you view projects',
                  style: TextStyle(fontSize: 14, color: AppColors.gray500),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: AppColors.gray500),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<(String, String)> options,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface(context),
          ),
        ),
        const SizedBox(height: 12),
        ...options.map((opt) {
          final (value, label) = opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                onChanged(value);
                widget.onApply(
                  title == 'Status' ? value : _status,
                  title == 'Sort By' ? value : _sortBy,
                );
              },
              child: Row(
                children: [
                  _RadioDot(selected: selected == value),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurface(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _status = 'all';
            _sortBy = 'recent';
          });
          widget.onApply('all', 'recent');
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          side: BorderSide(color: AppColors.border(context)),
          foregroundColor: AppColors.onSurface(context),
        ),
        child: const Text('Reset All Filters', style: TextStyle(fontSize: 14)),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.gray300,
          width: 2,
        ),
        color: selected ? AppColors.primary : Colors.transparent,
      ),
      child: selected
          ? const Center(
              child: CircleAvatar(radius: 4, backgroundColor: Colors.white),
            )
          : null,
    );
  }
}
