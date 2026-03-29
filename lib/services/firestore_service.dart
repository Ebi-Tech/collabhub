import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabhub/models/project_model.dart';

// Handles all Firestore reads/writes for projects
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _projects =>
      _db.collection('projects');

  // load all projects, newest first
  Future<List<ProjectModel>> getProjects({required String currentUserId}) async {
    final snapshot = await _projects
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProjectModel.fromMap(doc.id, doc.data(),
            currentUserId: currentUserId))
        .toList();
  }
// create a new project
  Future<ProjectModel> createProject(ProjectModel project) async {
    final data = project.toMap();
    final docRef = await _projects.add(data);
    return project.copyWith(id: docRef.id);
  }

  // only update editable fields, not votes or author info
  Future<ProjectModel> updateProject(ProjectModel project) async {
    await _projects.doc(project.id).update({
      'title': project.title,
      'description': project.description,
      'skills': project.skills,
      'contactEmail': project.contactEmail,
      'status': project.isOpen ? 'open' : 'closed',
    });
    return project;
  }

  Future<void> deleteProject(String projectId) async {
    await _projects.doc(projectId).delete();
  }

  // uses a transaction so two users voting at the same time don't clobber each other
  // tapping the same button again removes the vote; switching sides swaps it
  Future<ProjectModel> toggleVote(
    String projectId, {
    required bool isUpvote,
    required String userId,
  }) async {
    final docRef = _projects.doc(projectId);

    return _db.runTransaction<ProjectModel>((txn) async {
      final snap = await txn.get(docRef);
      if (!snap.exists) throw Exception('Project not found');

      final data = snap.data()!;
      final votes = Map<String, dynamic>.from(data['votes'] as Map? ?? {});
      int up = (data['upvotes'] as num?)?.toInt() ?? 0;
      int down = (data['downvotes'] as num?)?.toInt() ?? 0;

      final current = votes[userId] as String?;

      if (isUpvote) {
        if (current == 'up') {
          votes.remove(userId);
          up--;
        } else {
          if (current == 'down') down--;
          votes[userId] = 'up';
          up++;
        }
      } else {
        if (current == 'down') {
          votes.remove(userId);
          down--;
        } else {
          if (current == 'up') up--;
          votes[userId] = 'down';
          down++;
        }
      }

      txn.update(docRef, {'upvotes': up, 'downvotes': down, 'votes': votes});

      return ProjectModel.fromMap(snap.id, {
        ...data,
        'upvotes': up,
        'downvotes': down,
        'votes': votes,
      }, currentUserId: userId);
    });
  }
}
