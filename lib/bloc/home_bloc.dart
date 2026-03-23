import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collabhub/bloc/home_event.dart';
import 'package:collabhub/bloc/home_state.dart';
import 'package:collabhub/models/project_model.dart';
import 'package:collabhub/services/firestore_service.dart';
import 'package:collabhub/services/prefs_service.dart';

export 'home_event.dart';
export 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirestoreService _firestoreService;
  final PrefsService _prefsService;
  String _currentUserId = '';

  HomeBloc({
    required FirestoreService firestoreService,
    required PrefsService prefsService,
  })  : _firestoreService = firestoreService,
        _prefsService = prefsService,
        super(const HomeInitial()) {
    on<HomeLoadProjects>(_onLoad);
    on<HomeSearchChanged>(_onSearch);
    on<HomeFilterChanged>(_onFilter);
    on<HomeUpvoteProject>(_onUpvote);
    on<HomeDownvoteProject>(_onDownvote);
    on<HomeToggleProjectStatus>(_onToggleStatus);
    on<HomeDeleteProject>(_onDelete);
    on<HomeUpdateProject>(_onUpdate);
    on<HomeAddProject>(_onAdd);
  }

  // ── handlers ──────────────────────────────────────────────────────────────

  Future<void> _onLoad(HomeLoadProjects event, Emitter<HomeState> emit) async {
    _currentUserId = event.userId;
    emit(const HomeLoading());
    try {
      // Restore saved filter/sort preferences
      final savedFilter = await _prefsService.getStatusFilter();
      final savedSort = await _prefsService.getSortBy();
      final projects = await _firestoreService.getProjects(
        currentUserId: _currentUserId,
      );
      emit(HomeLoaded(
        allProjects: projects,
        statusFilter: savedFilter,
        sortBy: savedSort,
        displayedProjects: _applyFilters(projects, savedFilter, savedSort, ''),
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void _onSearch(HomeSearchChanged event, Emitter<HomeState> emit) {
    if (state is! HomeLoaded) return;
    final s = state as HomeLoaded;
    emit(s.copyWith(
      searchQuery: event.query,
      displayedProjects: _applyFilters(
        s.allProjects,
        s.statusFilter,
        s.sortBy,
        event.query,
      ),
    ));
  }

  void _onFilter(HomeFilterChanged event, Emitter<HomeState> emit) {
    if (state is! HomeLoaded) return;
    final s = state as HomeLoaded;
    // Persist the user's chosen filter + sort
    _prefsService.saveStatusFilter(event.statusFilter);
    _prefsService.saveSortBy(event.sortBy);
    emit(s.copyWith(
      statusFilter: event.statusFilter,
      sortBy: event.sortBy,
      displayedProjects: _applyFilters(
        s.allProjects,
        event.statusFilter,
        event.sortBy,
        s.searchQuery,
      ),
    ));
  }

  Future<void> _onUpvote(HomeUpvoteProject event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;
    try {
      final updated = await _firestoreService.toggleVote(
        event.projectId,
        isUpvote: true,
        userId: event.userId,
      );
      _replaceAndEmit(updated, emit);
    } catch (e) {
      final s = state as HomeLoaded;
      emit(s.copyWith(transientError: 'Vote failed: $e'));
    }
  }

  Future<void> _onDownvote(HomeDownvoteProject event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;
    try {
      final updated = await _firestoreService.toggleVote(
        event.projectId,
        isUpvote: false,
        userId: event.userId,
      );
      _replaceAndEmit(updated, emit);
    } catch (e) {
      final s = state as HomeLoaded;
      emit(s.copyWith(transientError: 'Vote failed: $e'));
    }
  }

  Future<void> _onToggleStatus(
    HomeToggleProjectStatus event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    final s = state as HomeLoaded;
    final idx = s.allProjects.indexWhere((p) => p.id == event.projectId);
    if (idx == -1) return;

    final project = s.allProjects[idx];
    final toggled = project.copyWith(
      status: project.isOpen ? ProjectStatus.closed : ProjectStatus.open,
    );
    try {
      final updated = await _firestoreService.updateProject(toggled);
      _replaceAndEmit(updated, emit);
    } catch (e) {
      emit(s.copyWith(transientError: 'Status update failed: $e'));
    }
  }

  Future<void> _onDelete(HomeDeleteProject event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;
    final s = state as HomeLoaded;
    try {
      await _firestoreService.deleteProject(event.projectId);
      final updated = s.allProjects.where((p) => p.id != event.projectId).toList();
      emit(s.copyWith(
        allProjects: updated,
        displayedProjects:
            _applyFilters(updated, s.statusFilter, s.sortBy, s.searchQuery),
      ));
    } catch (e) {
      emit(s.copyWith(transientError: 'Delete failed: $e'));
    }
  }

  Future<void> _onUpdate(HomeUpdateProject event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;
    final s = state as HomeLoaded;
    try {
      final updated = await _firestoreService.updateProject(event.project);
      _replaceAndEmit(updated, emit);
    } catch (e) {
      emit(s.copyWith(transientError: 'Update failed: $e'));
    }
  }

  Future<void> _onAdd(HomeAddProject event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;
    final s = state as HomeLoaded;
    try {
      final created = await _firestoreService.createProject(event.project);
      final updated = [created, ...s.allProjects];
      emit(s.copyWith(
        allProjects: updated,
        displayedProjects:
            _applyFilters(updated, s.statusFilter, s.sortBy, s.searchQuery),
        lastAddedId: created.id,
        transientError: null,
      ));
    } catch (e) {
      emit(s.copyWith(transientError: 'Failed to post project: $e'));
    }
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  void _replaceAndEmit(ProjectModel project, Emitter<HomeState> emit) {
    final s = state as HomeLoaded;
    final updated = s.allProjects
        .map((p) => p.id == project.id ? project : p)
        .toList();
    emit(s.copyWith(
      allProjects: updated,
      displayedProjects:
          _applyFilters(updated, s.statusFilter, s.sortBy, s.searchQuery),
    ));
  }

  List<ProjectModel> _applyFilters(
    List<ProjectModel> projects,
    String statusFilter,
    String sortBy,
    String query,
  ) {
    var list = projects.toList();

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.skills.any((s) => s.toLowerCase().contains(q)) ||
            p.authorName.toLowerCase().contains(q);
      }).toList();
    }

    if (statusFilter == 'open') {
      list = list.where((p) => p.isOpen).toList();
    } else if (statusFilter == 'closed') {
      list = list.where((p) => !p.isOpen).toList();
    }

    switch (sortBy) {
      case 'upvoted':
        list.sort((a, b) => b.upvotes.compareTo(a.upvotes));
        break;
      case 'downvoted':
        list.sort((a, b) => b.downvotes.compareTo(a.downvotes));
        break;
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return list;
  }
}
