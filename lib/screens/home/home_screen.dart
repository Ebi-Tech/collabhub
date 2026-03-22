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