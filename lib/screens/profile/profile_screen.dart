import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:collabhub/bloc/auth_bloc.dart';
import 'package:collabhub/bloc/home_bloc.dart';
import 'package:collabhub/bloc/theme_cubit.dart';
import 'package:collabhub/models/project_model.dart';
import 'package:collabhub/models/user_model.dart';
import 'package:collabhub/utils/constants.dart';
import 'package:collabhub/utils/validators.dart';
import 'package:collabhub/widgets/edit_post_dialog.dart';
import 'package:collabhub/widgets/skill_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editMode = false;

  void _toggleEdit() => setState(() => _editMode = !_editMode);

  void _onSaved() => setState(() => _editMode = false);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = authState.user;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 672),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Profile', style: AppTextStyles.heading2xl),
                            SizedBox(height: 4),
                            Text('Manage your information',
                                style: AppTextStyles.bodySm),
                          ],
                        ),
                      ),
                      if (!_editMode)
                        OutlinedButton.icon(
                          onPressed: _toggleEdit,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            side: BorderSide(color: AppColors.border(context)),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xl)),
                            foregroundColor: AppColors.onSurface(context),
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Profile card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      border: Border.all(color: AppColors.border(context)),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: AppShadows.card,
                    ),
                    child: _editMode
                        ? _EditForm(
                            user: user,
                            onSaved: _onSaved,
                            onCancel: _toggleEdit,
                          )
                        : _ViewProfile(user: user),
                  ),
                  // My Posts
                  _MyPosts(userId: user.id),
                  const SizedBox(height: 24),
                  // Dark mode toggle
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, mode) {
                      final isDark = mode == ThemeMode.dark;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          border: Border.all(color: AppColors.border(context)),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          boxShadow: AppShadows.card,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isDark
                                  ? Icons.dark_mode_outlined
                                  : Icons.light_mode_outlined,
                              size: 20,
                              color: AppColors.gray500,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Dark Mode',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurface(context),
                                ),
                              ),
                            ),
                            Switch(
                              value: isDark,
                              onChanged: (_) =>
                                  context.read<ThemeCubit>().toggle(),
                              activeThumbColor: AppColors.primary,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Logout
                  OutlinedButton.icon(
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(const AuthLogoutRequested());
                    },
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      side: BorderSide(color: AppColors.border(context)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xl)),
                      foregroundColor: AppColors.onSurface(context),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── View mode ─────────────────────────────────────────────────────────────────

class _ViewProfile extends StatelessWidget {
  final UserModel user;
  const _ViewProfile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar
        _BigAvatar(
          initials: user.initials,
          userId: user.id,
          avatarUrl: user.avatarUrl,
        ),
        const SizedBox(height: 12),
        Text(user.name, style: AppTextStyles.headingLg),
        const SizedBox(height: 2),
        Text(
          user.role.isEmpty ? 'University Student' : user.role,
          style: AppTextStyles.bodySm,
        ),
        const SizedBox(height: 24),
        // Email
        _infoRow(context, Icons.email_outlined, user.email, isLink: true),
        const SizedBox(height: 20),
        // Bio
        _section(
          'Bio',
          user.bio.isEmpty
              ? const Text('No bio yet.',
                  style: TextStyle(fontSize: 14, color: AppColors.gray500))
              : Text(user.bio,
                  style: TextStyle(
                      fontSize: 16,
                      color: AppColors.onSurface(context),
                      height: 1.5)),
        ),
        const SizedBox(height: 20),
        // Skills
        _section(
          'Skills',
          user.skills.isEmpty
              ? const Text('No skills added yet.',
                  style: TextStyle(fontSize: 14, color: AppColors.gray500))
              : Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children:
                      user.skills.map((s) => SkillBadge(label: s)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text,
      {bool isLink = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gray500),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isLink ? AppColors.primary : AppColors.onSurface(context),
          ),
        ),
      ],
    );
  }

  Widget _section(String label, Widget child) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray500)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

// ── Edit mode ─────────────────────────────────────────────────────────────────

class _EditForm extends StatefulWidget {
  final UserModel user;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const _EditForm({
    required this.user,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _bioCtrl;
  final TextEditingController _skillCtrl = TextEditingController();
  late List<String> _skills;
  String? _avatarLocalPath; // set when user picks a new photo

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _roleCtrl = TextEditingController(text: widget.user.role);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _bioCtrl = TextEditingController(text: widget.user.bio);
    _skills = List.from(widget.user.skills);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (picked != null) setState(() => _avatarLocalPath = picked.path);
  }

  void _addSkill() {
    final s = _skillCtrl.text.trim();
    if (s.isEmpty || _skills.contains(s)) return;
    setState(() => _skills.add(s));
    _skillCtrl.clear();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthProfileUpdateRequested(
          name: _nameCtrl.text.trim(),
          role: _roleCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          skills: List.from(_skills),
          avatarLocalPath: _avatarLocalPath,
        ));
    widget.onSaved();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.green600,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _BigAvatar(
            initials: widget.user.initials,
            userId: widget.user.id,
            avatarUrl: widget.user.avatarUrl,
            localPath: _avatarLocalPath,
            onTap: _pickPhoto,
          ),
          const SizedBox(height: 20),
          _fieldRow('Name', _nameCtrl, 'Your name',
              validator: (v) => Validators.required(v, field: 'Name')),
          const SizedBox(height: 14),
          _fieldRow('Role / Field of Study', _roleCtrl,
              'e.g., Computer Science Student'),
          const SizedBox(height: 14),
          _fieldRow('Email', _emailCtrl, 'your.email@university.edu',
              keyboard: TextInputType.emailAddress,
              validator: Validators.email),
          const SizedBox(height: 14),
          _fieldRow('Bio', _bioCtrl, 'Tell us about yourself...',
              maxLines: 4),
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Skills', style: AppTextStyles.labelBase),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _rawInput(_skillCtrl, 'Add a skill',
                    onSubmitted: (_) => _addSkill()),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _addSkill,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.actionButton(context),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: const Text('Add',
                      style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
          if (_skills.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _skills
                  .map((s) =>
                      SkillBadge(label: s, onRemove: () => setState(() => _skills.remove(s))))
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.actionButton(context),
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl)),
                    foregroundColor: AppColors.onSurface(context),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fieldRow(
    String label,
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelBase),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboard,
          validator: validator,
          style: TextStyle(fontSize: 16, color: AppColors.onSurface(context)),
          decoration: _dec(hint),
        ),
      ],
    );
  }

  Widget _rawInput(
    TextEditingController ctrl,
    String hint, {
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: ctrl,
      onSubmitted: onSubmitted,
      style: TextStyle(fontSize: 16, color: AppColors.onSurface(context)),
      decoration: _dec(hint),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.gray400, fontSize: 16),
        filled: true,
        fillColor: AppColors.input(context),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: AppColors.red600),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: AppColors.red600, width: 2),
        ),
      );
}

// ── Big avatar ────────────────────────────────────────────────────────────────

class _BigAvatar extends StatelessWidget {
  final String initials;
  final String userId;
  final String? avatarUrl;   // remote URL (Google photo / Storage)
  final String? localPath;   // local file picked but not yet uploaded
  final VoidCallback? onTap; // non-null = edit mode, shows camera icon

  const _BigAvatar({
    required this.initials,
    required this.userId,
    this.avatarUrl,
    this.localPath,
    this.onTap,
  });

  Color _color() {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
    ];
    return colors[userId.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (localPath != null) {
      image = FileImage(File(localPath!));
    } else if (avatarUrl != null) {
      image = NetworkImage(avatarUrl!);
    }

    final avatar = CircleAvatar(
      radius: 48,
      backgroundColor: _color(),
      backgroundImage: image,
      child: image == null
          ? Text(
              initials,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
          : null,
    );

    if (onTap == null) return avatar;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── My Posts ──────────────────────────────────────────────────────────────────

class _MyPosts extends StatelessWidget {
  final String userId;
  const _MyPosts({required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();
        final myPosts = state.allProjects
            .where((p) => p.authorId == userId)
            .toList();
        if (myPosts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              'My Posts (${myPosts.length})',
              style: AppTextStyles.headingXl,
            ),
            const SizedBox(height: 16),
            ...myPosts.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PostItem(
                    project: p,
                    onEdit: () => showDialog(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        value: context.read<HomeBloc>(),
                        child: EditPostDialog(project: p),
                      ),
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }
}

class _PostItem extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onEdit;

  const _PostItem({required this.project, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface(context)),
                ),
                const SizedBox(height: 4),
                Text(
                  project.description,
                  style: TextStyle(
                      fontSize: 14, color: AppColors.secondaryText(context), height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: project.skills.map((s) => _tinyBadge(context, s)).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statusBadge(context, project.isOpen),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_upward,
                        size: 14, color: AppColors.gray500),
                    Text(' ${project.upvotes}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.gray500)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_downward,
                        size: 14, color: AppColors.gray500),
                    Text(' ${project.downvotes}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.gray500)),
                  ],
                ),
              ],
            ),
          ),
          // Three-dot menu
          _PostMenu(project: project, onEdit: onEdit),
        ],
      ),
    );
  }

  Widget _tinyBadge(BuildContext context, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.badgeBg(context),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 12, color: AppColors.onSurface(context))),
      );

  Widget _statusBadge(BuildContext context, bool isOpen) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isOpen ? AppColors.green100 : AppColors.gray100,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          isOpen ? 'Open' : 'Closed',
          style: TextStyle(
            fontSize: 12,
            color: isOpen ? AppColors.green700 : AppColors.secondaryText(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}

// ── Three-dot menu for profile post items ─────────────────────────────────────

class _PostMenu extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onEdit;

  const _PostMenu({required this.project, required this.onEdit});

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
      onSelected: (value) => _handle(context, value),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'edit',
          child: _item(Icons.edit_outlined, 'Edit Post', AppColors.onSurface(ctx)),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: _item(
            project.isOpen
                ? Icons.cancel_outlined
                : Icons.check_circle_outline,
            project.isOpen ? 'Mark as Closed' : 'Mark as Open',
            AppColors.onSurface(ctx),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: _item(Icons.delete_outline, 'Delete Post', AppColors.red600),
        ),
      ],
    );
  }

  Widget _item(IconData icon, String label, Color color) => Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 14, color: color)),
        ],
      );

  void _handle(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        onEdit();
        break;
      case 'toggle':
        context.read<HomeBloc>().add(HomeToggleProjectStatus(project.id));
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl)),
            title: const Text('Delete Post',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            content: Text(
              'Are you sure you want to delete this post? This cannot be undone.',
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
                  context
                      .read<HomeBloc>()
                      .add(HomeDeleteProject(project.id));
                },
                child: const Text('Delete',
                    style: TextStyle(color: AppColors.red600)),
              ),
            ],
          ),
        );
        break;
    }
  }
}
