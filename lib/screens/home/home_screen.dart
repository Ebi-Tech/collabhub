import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collabhub/bloc/auth_bloc.dart';
import 'package:collabhub/bloc/home_bloc.dart';
import 'package:collabhub/models/project_model.dart';
import 'package:collabhub/utils/constants.dart';
import 'package:collabhub/widgets/edit_post_dialog.dart';
import 'package:collabhub/widgets/filter_sheet.dart';
import 'package:collabhub/widgets/project_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openFilter(BuildContext context, HomeLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilterSheet(
            initialStatus: state.statusFilter,
            initialSortBy: state.sortBy,
            onApply: (status, sortBy) {
              context.read<HomeBloc>().add(
                HomeFilterChanged(statusFilter: status, sortBy: sortBy),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openEditDialog(BuildContext context, ProjectModel project) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<HomeBloc>(),
        child: EditPostDialog(project: project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Column(
          children: [
            _SearchBar(
              controller: _searchCtrl,
              onChanged: (q) =>
                  context.read<HomeBloc>().add(HomeSearchChanged(q)),
              onClear: () {
                _searchCtrl.clear();
                context.read<HomeBloc>().add(const HomeSearchChanged(''));
              },
              onFilter: state is HomeLoaded
                  ? () => _openFilter(context, state)
                  : null,
              activeFilterCount: state is HomeLoaded
                  ? _filterCount(state)
                  : 0,
            ),
            Expanded(child: _Body(state: state, onEdit: _openEditDialog)),
          ],
        );
      },
    );
  }

  int _filterCount(HomeLoaded s) {
    int c = 0;
    if (s.statusFilter != 'all') c++;
    if (s.sortBy != 'recent') c++;
    return c;
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback? onFilter;
  final int activeFilterCount;
