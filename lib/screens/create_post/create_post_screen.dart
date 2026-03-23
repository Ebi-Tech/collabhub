import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collabhub/bloc/auth_bloc.dart';
import 'package:collabhub/bloc/home_bloc.dart';
import 'package:collabhub/models/project_model.dart';
import 'package:collabhub/utils/constants.dart';
import 'package:collabhub/utils/validators.dart';
import 'package:collabhub/widgets/skill_badge.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _skillCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final List<String> _skills = [];
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill email from auth
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _emailCtrl.text = authState.user.email;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _skillCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _addSkill() {
    final s = _skillCtrl.text.trim();
    if (s.isEmpty || _skills.contains(s)) return;
    setState(() => _skills.add(s));
    _skillCtrl.clear();
  }

  void _post() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;

    setState(() => _isPosting = true);

    final project = ProjectModel(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      skills: List.from(_skills),
      contactEmail: _emailCtrl.text.trim(),
      status: ProjectStatus.open,
      upvotes: 0,
      downvotes: 0,
      authorId: user.id,
      authorName: user.name,
      authorRole: user.role,
      createdAt: DateTime.now(),
    );

    context.read<HomeBloc>().add(HomeAddProject(project));
    // UI waits — BlocListener below handles success / error
  }

  void _resetForm() {
    final authState = context.read<AuthBloc>().state;
    _titleCtrl.clear();
    _descCtrl.clear();
    _skillCtrl.clear();
    if (authState is AuthAuthenticated) {
      _emailCtrl.text = authState.user.email;
    }
    setState(() {
      _skills.clear();
      _isPosting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (prev, curr) {
        if (curr is! HomeLoaded) return false;
        final p = prev is HomeLoaded ? prev : null;
        // Fire when a new project was just added or a transient error arrived
        final addedChanged = curr.lastAddedId != null &&
            curr.lastAddedId != p?.lastAddedId;
        final errorChanged = curr.transientError != null &&
            curr.transientError != p?.transientError;
        return addedChanged || errorChanged;
      },
      listener: (context, state) {
        if (state is! HomeLoaded) return;
        if (state.lastAddedId != null) {
          _resetForm();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Project posted successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.green600,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl)),
            duration: const Duration(seconds: 2),
          ));
        } else if (state.transientError != null) {
          setState(() => _isPosting = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.transientError!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.red600,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl)),
            duration: const Duration(seconds: 4),
          ));
        }
      },
      child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 672),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create Project', style: AppTextStyles.heading2xl),
              const SizedBox(height: 4),
              const Text(
                'Post your project and find teammates',
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  border: Border.all(color: AppColors.border(context)),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: AppShadows.card,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Project Title'),
                      const SizedBox(height: 6),
                      _input(
                        ctrl: _titleCtrl,
                        hint: 'e.g., AI-powered study planner',
                        validator: (v) =>
                            Validators.required(v, field: 'Title'),
                      ),
                      const SizedBox(height: 16),
                      _label('Description'),
                      const SizedBox(height: 6),
                      _input(
                        ctrl: _descCtrl,
                        hint:
                            "Describe your project idea, goals, and what you're looking for...",
                        maxLines: 5,
                        validator: (v) => Validators.minLength(v, 10,
                            field: 'Description'),
                      ),
                      const SizedBox(height: 16),
                      _label('Required Skills'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _input(
                              ctrl: _skillCtrl,
                              hint: 'e.g., React, Python, UI/UX',
                              onSubmitted: (_) => _addSkill(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _AddBtn(onTap: _addSkill),
                        ],
                      ),
                      if (_skills.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: _skills
                              .map((s) => SkillBadge(
                                    label: s,
                                    onRemove: () =>
                                        setState(() => _skills.remove(s)),
                                  ))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _label('Contact Email'),
                      const SizedBox(height: 6),
                      _input(
                        ctrl: _emailCtrl,
                        hint: 'your.email@university.edu',
                        keyboard: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isPosting ? null : _post,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.actionButton(context),
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xl)),
                          ),
                          child: _isPosting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  'Post Project',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),   // end SingleChildScrollView
  );     // end BlocListener
  }

  Widget _label(String text) =>
      Text(text, style: AppTextStyles.labelBase);

  Widget _input({
    required TextEditingController ctrl,
    required String hint,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: TextStyle(fontSize: 16, color: AppColors.onSurface(context)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.gray400, fontSize: 16),
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
      ),
    );
  }
}

class _AddBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _AddBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.actionButton(context),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: const Text(
          'Add',
          style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
      ),
    );
  }
}
