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
child: ValueListenableBuilder<TextEditingValue>(
  valueListenable: controller,
  builder: (context, value, _) {
    return TextField(
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
        suffixIcon: value.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 16, color: AppColors.gray400),
                onPressed: onClear,
              )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        isDense: true,
      ),
    );
  },
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

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
final HomeState state;
final void Function(BuildContext, ProjectModel) onEdit;

const _Body({required this.state, required this.onEdit});

@override
Widget build(BuildContext context) {
if (state is HomeLoading) {
return const Center(
child: CircularProgressIndicator(color: AppColors.primary),
);
}

if (state is HomeError) {
return Center(
child: Text((state as HomeError).message,
style: const TextStyle(color: AppColors.red600)),
);
}

if (state is HomeLoaded) {
final s = state as HomeLoaded;
final currentUserId =
(context.read<AuthBloc>().state is AuthAuthenticated)
? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
    : '';

if (s.displayedProjects.isEmpty) {
return Center(
child: Padding(
padding: const EdgeInsets.all(32),
child: Text(
s.searchQuery.isNotEmpty || s.hasActiveFilters
? 'No projects match your search.'
    : 'No projects yet. Be the first to post!',
textAlign: TextAlign.center,
style: const TextStyle(fontSize: 14, color: AppColors.gray500),
),
),
);
}

return ListView.separated(
padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
itemCount: s.displayedProjects.length +
(s.searchQuery.isNotEmpty || s.hasActiveFilters ? 1 : 0),
separatorBuilder: (_, __) => const SizedBox(height: 16),
itemBuilder: (context, index) {
if (index == 0 &&
(s.searchQuery.isNotEmpty || s.hasActiveFilters)) {
return Padding(
padding: const EdgeInsets.only(bottom: 4),
child: Text(
'Found ${s.displayedProjects.length} project(s)',
style: TextStyle(fontSize: 14, color: AppColors.secondaryText(context)),
),
);
}
final offset =
(s.searchQuery.isNotEmpty || s.hasActiveFilters) ? 1 : 0;
final cardIndex = index - offset;
final project = s.displayedProjects[cardIndex];
return _AnimatedCard(
index: cardIndex,
child: ProjectCard(
project: project,
isOwner: project.authorId == currentUserId,
onEdit: () => onEdit(context, project),
),
);
},
);
}

return const SizedBox.shrink();
}
}

// ── Staggered fade-in wrapper ──────────────────────────────────────────────────

class _AnimatedCard extends StatelessWidget {
final int index;
final Widget child;

const _AnimatedCard({required this.index, required this.child});

@override
Widget build(BuildContext context) {
// Cap delay so long lists don't wait forever
final delay = Duration(milliseconds: (index * 50).clamp(0, 300));
return TweenAnimationBuilder<double>(
tween: Tween(begin: 0, end: 1),
duration: Duration(milliseconds: 300 + delay.inMilliseconds),
curve: Curves.easeOut,
builder: (context, value, child) => Opacity(
opacity: value,
child: Transform.translate(
offset: Offset(0, 16 * (1 - value)),
child: child,
),
),
child: child,
);
}
}