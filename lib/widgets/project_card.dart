import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collabhub/bloc/auth_bloc.dart';
import 'package:collabhub/bloc/home_bloc.dart';
import 'package:collabhub/models/project_model.dart';
import 'package:collabhub/utils/constants.dart';
import 'package:collabhub/widgets/skill_badge.dart';

class ProjectCard extends StatefulWidget {
  final ProjectModel project;
  final bool isOwner;
  final VoidCallback? onEdit;

  const ProjectCard({
    super.key,
    required this.project,
    this.isOwner = false,
    this.onEdit,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          border: Border.all(color: AppColors.border(context)),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppShadows.card,
        ),
        child: Opacity(
          opacity: widget.project.isOpen ? 1.0 : 0.6,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardHeader(
                  project: widget.project,
                  isOwner: widget.isOwner,
                  onEdit: widget.onEdit,
                ),
                const SizedBox(height: 10),
                _ProjectContent(project: widget.project),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final ProjectModel project;
  final bool isOwner;
  final VoidCallback? onEdit;

  const _CardHeader({
    required this.project,
    required this.isOwner,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AuthorAvatar(
          initials: project.authorInitials,
          authorId: project.authorId,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.authorName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                project.authorRole,
                style: const TextStyle(fontSize: 12, color: AppColors.gray500),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _VoteButton(
              project: project,
              isUpvote: true,
            ),
            const SizedBox(width: 4),
            _VoteButton(
              project: project,
              isUpvote: false,
            ),
            if (isOwner) ...[
              const SizedBox(width: 4),
              _OwnerMenu(project: project, onEdit: onEdit),
            ],
          ],
        ),
      ],
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  final String initials;
  final String authorId;

  const _AuthorAvatar({required this.initials, required this.authorId});

  Color _avatarColor() {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFFEF4444),
    ];
    return colors[authorId.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: _avatarColor(),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final ProjectModel project;
  final bool isUpvote;

  const _VoteButton({required this.project, required this.isUpvote});

  @override
  Widget build(BuildContext context) {
    final active = isUpvote ? project.userUpvoted : project.userDownvoted;
    final count = isUpvote ? project.upvotes : project.downvotes;

    final activeBg = isUpvote ? AppColors.green100 : AppColors.red100;
    final activeText = isUpvote ? AppColors.green700 : AppColors.red700;

    return GestureDetector(
      onTap: () {
        final authState = context.read<AuthBloc>().state;
        if (authState is! AuthAuthenticated) return;
        final userId = authState.user.id;
        if (isUpvote) {
          context.read<HomeBloc>().add(
                HomeUpvoteProject(projectId: project.id, userId: userId),
              );
        } else {
          context.read<HomeBloc>().add(
                HomeDownvoteProject(projectId: project.id, userId: userId),
              );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUpvote
                  ? (active ? Icons.thumb_up : Icons.thumb_up_outlined)
                  : (active ? Icons.thumb_down : Icons.thumb_down_outlined),
              size: 16,
              color: active ? activeText : AppColors.secondaryText(context),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: active ? activeText : AppColors.secondaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// only visible to the person who posted the project
class _OwnerMenu extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onEdit;

  const _OwnerMenu({required this.project, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: AppColors.gray500),
      padding: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      elevation: 4,
      onSelected: (value) => _handleMenu(context, value),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'edit',
          child: _menuItem(Icons.edit_outlined, 'Edit Post', AppColors.onSurface(ctx)),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: _menuItem(
            project.isOpen ? Icons.cancel_outlined : Icons.check_circle_outline,
            project.isOpen ? 'Mark as Closed' : 'Mark as Open',
            AppColors.onSurface(ctx),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: _menuItem(Icons.delete_outline, 'Delete Post', AppColors.red600),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 14, color: color)),
      ],
    );
  }

  void _handleMenu(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        onEdit?.call();
        break;
      case 'toggle':
        context.read<HomeBloc>().add(HomeToggleProjectStatus(project.id));
        _showToast(
          context,
          project.isOpen ? 'Post marked as closed' : 'Post marked as open',
        );
        break;
      case 'delete':
        _confirmDelete(context);
        break;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text('Delete Post',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: AppColors.secondaryText(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<HomeBloc>().add(HomeDeleteProject(project.id));
              _showToast(context, 'Post deleted');
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.red600)),
          ),
        ],
      ),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ProjectContent extends StatelessWidget {
  final ProjectModel project;

  const _ProjectContent({required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                project.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(isOpen: project.isOpen),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          project.description,
          style: TextStyle(fontSize: 14, color: AppColors.secondaryText(context), height: 1.5),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: project.skills
              .map((s) => SkillBadge(label: s))
              .toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.email_outlined, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              project.contactEmail,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isOpen;
  const _StatusBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.green600 : AppColors.gray500,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
