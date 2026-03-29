import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ProjectStatus { open, closed }

class ProjectModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> skills;
  final String contactEmail;
  final ProjectStatus status;
  final int upvotes;
  final int downvotes;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String? authorAvatarUrl;
  final DateTime createdAt;
  final bool userUpvoted;
  final bool userDownvoted;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.skills,
    required this.contactEmail,
    required this.status,
    required this.upvotes,
    required this.downvotes,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.authorAvatarUrl,
    required this.createdAt,
    this.userUpvoted = false,
    this.userDownvoted = false,
  });

  bool get isOpen => status == ProjectStatus.open;

  // fallback when the author has no profile photo
  String get authorInitials {
    final parts = authorName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return authorName.isNotEmpty ? authorName[0].toUpperCase() : '?';
  }

  // currentUserId is needed to figure out how the current user voted
  factory ProjectModel.fromMap(
    String id,
    Map<String, dynamic> data, {
    required String currentUserId,
  }) {
    final votes = Map<String, dynamic>.from(data['votes'] as Map? ?? {});
    final ts = data['createdAt'];
    return ProjectModel(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      skills: List<String>.from(data['skills'] as List? ?? []),
      contactEmail: data['contactEmail'] as String? ?? '',
      status: (data['status'] as String?) == 'closed'
          ? ProjectStatus.closed
          : ProjectStatus.open,
      upvotes: (data['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (data['downvotes'] as num?)?.toInt() ?? 0,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      authorRole: data['authorRole'] as String? ?? '',
      authorAvatarUrl: data['authorAvatarUrl'] as String?,
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      userUpvoted: votes[currentUserId] == 'up',
      userDownvoted: votes[currentUserId] == 'down',
    );
  }

  // id and votes are not included — Firestore manages the id, votes live separately
  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'skills': skills,
        'contactEmail': contactEmail,
        'status': isOpen ? 'open' : 'closed',
        'upvotes': upvotes,
        'downvotes': downvotes,
        'votes': <String, dynamic>{},
        'authorId': authorId,
        'authorName': authorName,
        'authorRole': authorRole,
        'authorAvatarUrl': authorAvatarUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? skills,
    String? contactEmail,
    ProjectStatus? status,
    int? upvotes,
    int? downvotes,
    String? authorId,
    String? authorName,
    String? authorRole,
    String? authorAvatarUrl,
    DateTime? createdAt,
    bool? userUpvoted,
    bool? userDownvoted,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      skills: skills ?? this.skills,
      contactEmail: contactEmail ?? this.contactEmail,
      status: status ?? this.status,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      createdAt: createdAt ?? this.createdAt,
      userUpvoted: userUpvoted ?? this.userUpvoted,
      userDownvoted: userDownvoted ?? this.userDownvoted,
    );
  }

  @override
  List<Object?> get props => [
        id, title, description, skills, contactEmail, status,
        upvotes, downvotes, authorId, authorName, authorRole,
        authorAvatarUrl, createdAt, userUpvoted, userDownvoted,
      ];
}
