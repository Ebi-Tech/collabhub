import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collabhub/bloc/home_bloc.dart';
import 'package:collabhub/models/project_model.dart';
import 'package:collabhub/utils/constants.dart';
import 'package:collabhub/utils/validators.dart';
import 'package:collabhub/widgets/skill_badge.dart';

/// Full-screen dialog for editing an existing project post.
class EditPostDialog extends StatefulWidget {
  final ProjectModel project;

  const EditPostDialog({super.key, required this.project});

  @override
  State<EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends State<EditPostDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  final TextEditingController _skillCtrl = TextEditingController();
  late List<String> _skills;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.project.title);
    _descCtrl = TextEditingController(text: widget.project.description);
    _skills = List.from(widget.project.skills);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  void _addSkill() {
    final s = _skillCtrl.text.trim();
    if (s.isEmpty || _skills.contains(s)) return;
    setState(() => _skills.add(s));
    _skillCtrl.clear();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final updated = widget.project.copyWith(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      skills: List.from(_skills),
    );
    context.read<HomeBloc>().add(HomeUpdateProject(updated));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Post updated!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 448),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row: centered title + X close button
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Edit Post',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface(context)),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close,
                            size: 20, color: AppColors.gray500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _label('Project Title'),
                const SizedBox(height: 6),
                _input(
                  controller: _titleCtrl,
                  hint: 'e.g., AI-powered study planner',
                  validator: (v) => Validators.required(v, field: 'Title'),
                ),
                const SizedBox(height: 16),
                _label('Description'),
                const SizedBox(height: 6),
                _input(
                  controller: _descCtrl,
                  hint: 'Describe your project...',
                  maxLines: 4,
                  validator: (v) =>
                      Validators.minLength(v, 10, field: 'Description'),
                ),
                const SizedBox(height: 16),
                _label('Required Skills'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _input(
                        controller: _skillCtrl,
                        hint: 'Add a skill',
                        onSubmitted: (_) => _addSkill(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _AddButton(onTap: _addSkill),
                  ],
                ),
                if (_skills.isNotEmpty) ...[
                  const SizedBox(height: 10),
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: _primaryStyle(context),
                        child: const Text('Save Changes'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: _outlineStyle(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: AppTextStyles.labelBase,
      );

  Widget _input({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: TextStyle(fontSize: 16, color: AppColors.onSurface(context)),
      decoration: InputDecoration(
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
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2),
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

  ButtonStyle _primaryStyle(BuildContext context) => ElevatedButton.styleFrom(
        backgroundColor: AppColors.actionButton(context),
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        elevation: 0,
      );

  ButtonStyle _outlineStyle(BuildContext context) => OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl)),
        side: BorderSide(color: AppColors.border(context)),
        foregroundColor: AppColors.onSurface(context),
      );
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

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
