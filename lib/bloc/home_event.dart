import 'package:equatable/equatable.dart';
import 'package:collabhub/models/project_model.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeLoadProjects extends HomeEvent {
  final String userId;
  const HomeLoadProjects(this.userId);
  @override
  List<Object?> get props => [userId];
}

class HomeSearchChanged extends HomeEvent {
  final String query;
  const HomeSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class HomeFilterChanged extends HomeEvent {
  /// 'all' | 'open' | 'closed'
  final String statusFilter;

  /// 'recent' | 'upvoted' | 'downvoted'
  final String sortBy;

  const HomeFilterChanged({required this.statusFilter, required this.sortBy});
  @override
  List<Object?> get props => [statusFilter, sortBy];
}

class HomeUpvoteProject extends HomeEvent {
  final String projectId;
  final String userId;
  const HomeUpvoteProject({required this.projectId, required this.userId});
  @override
  List<Object?> get props => [projectId, userId];
}

class HomeDownvoteProject extends HomeEvent {
  final String projectId;
  final String userId;
  const HomeDownvoteProject({required this.projectId, required this.userId});
  @override
  List<Object?> get props => [projectId, userId];
}

class HomeToggleProjectStatus extends HomeEvent {
  final String projectId;
  const HomeToggleProjectStatus(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

class HomeDeleteProject extends HomeEvent {
  final String projectId;
  const HomeDeleteProject(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

class HomeUpdateProject extends HomeEvent {
  final ProjectModel project;
  const HomeUpdateProject(this.project);
  @override
  List<Object?> get props => [project];
}

class HomeAddProject extends HomeEvent {
  final ProjectModel project;
  const HomeAddProject(this.project);
  @override
  List<Object?> get props => [project];
}
