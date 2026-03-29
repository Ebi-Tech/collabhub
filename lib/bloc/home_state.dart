import 'package:equatable/equatable.dart';
import 'package:collabhub/models/project_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<ProjectModel> allProjects;
  final List<ProjectModel> displayedProjects;
  final String searchQuery;

  // 'all' | 'open' | 'closed'
  final String statusFilter;

  // 'recent' | 'upvoted' | 'downvoted'
  final String sortBy;

  // set after a post is created so the create screen can show a success snackbar
  final String? lastAddedId;

  // write errors (vote/delete/etc) that shouldn't kick us out of HomeLoaded
  final String? transientError;

  const HomeLoaded({
    required this.allProjects,
    required this.displayedProjects,
    this.searchQuery = '',
    this.statusFilter = 'all',
    this.sortBy = 'recent',
    this.lastAddedId,
    this.transientError,
  });

  // sentinel trick so copyWith can set nullable fields back to null
  static const _unset = Object();

  HomeLoaded copyWith({
    List<ProjectModel>? allProjects,
    List<ProjectModel>? displayedProjects,
    String? searchQuery,
    String? statusFilter,
    String? sortBy,
    Object? lastAddedId = _unset,
    Object? transientError = _unset,
  }) {
    return HomeLoaded(
      allProjects: allProjects ?? this.allProjects,
      displayedProjects: displayedProjects ?? this.displayedProjects,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      sortBy: sortBy ?? this.sortBy,
      lastAddedId:
          lastAddedId == _unset ? this.lastAddedId : lastAddedId as String?,
      transientError: transientError == _unset
          ? this.transientError
          : transientError as String?,
    );
  }

  bool get hasActiveFilters =>
      statusFilter != 'all' || sortBy != 'recent' || searchQuery.isNotEmpty;

  @override
  List<Object?> get props => [
        allProjects,
        displayedProjects,
        searchQuery,
        statusFilter,
        sortBy,
        lastAddedId,
        transientError,
      ];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
