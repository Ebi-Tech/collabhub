#lib/screens/home/home_screen.dart

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

const _SearchBar({
required this.controller,
required this.onChanged,
required this.onClear,
this.onFilter,
this.activeFilterCount = 0,
});

@override
Widget build(BuildContext context) {
return Container(
color: AppColors.surface(context),
padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
child: Row(
children: [
Expanded(
child: Container(
height: 40,
decoration: BoxDecoration(
color: AppColors.input(context),
borderRadius: BorderRadius.circular(AppRadius.xl),
),
child: TextField(
controller: controller,
onChanged: onChanged,
style: TextStyle(fontSize: 16, color: AppColors.onSurface(context)),
decoration: InputDecoration(
hintText: 'Search projects, skills, or people...',
hintStyle: const TextStyle(
fontSize: 16,
color: AppColors.gray400,
),
prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.gray400),
suffixIcon: controller.text.isNotEmpty
? IconButton(
icon: const Icon(Icons.close, size: 16, color: AppColors.gray400),
onPressed: onClear,
)
    : null,
border: InputBorder.none,
contentPadding: const EdgeInsets.symmetric(vertical: 10),
isDense: true,
),
),
),
),
const SizedBox(width: 8),
// Filter button
Stack(
clipBehavior: Clip.none,
children: [
OutlinedButton.icon(
onPressed: onFilter,
icon: const Icon(Icons.tune, size: 16),
label: const Text('Filter'),
style: OutlinedButton.styleFrom(
padding:
const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
foregroundColor: AppColors.onSurface(context),
side: const BorderSide(color: AppColors.cardBorder),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(AppRadius.xl),
),
textStyle: const TextStyle(fontSize: 14),
),
),
if (activeFilterCount > 0)
Positioned(
top: -4,
right: -4,
child: Container(
width: 20,
height: 20,
decoration: const BoxDecoration(
color: AppColors.primary,
shape: BoxShape.circle,
),
child: Center(
child: Text(
'$activeFilterCount',
style: const TextStyle(
color: Colors.white,
fontSize: 11,
fontWeight: FontWeight.w600),
),
),
),
),
],
),
],
),
);
}
}
