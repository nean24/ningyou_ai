import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';
import '../../../shared/widgets/ningyou/ningyou_avatar.dart';
import '../../../shared/widgets/ningyou/ningyou_button.dart';
import '../../../shared/widgets/ningyou/ningyou_text_field.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/profile_data_source.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final TextEditingController _nameController;
  XFile? _pickedImage;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authControllerProvider).valueOrNull;
    final name = authState is AuthAuthenticated ? authState.user.name : '';
    _nameController = TextEditingController(text: name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (file != null) setState(() => _pickedImage = file);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Tên không được để trống.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final ds = ref.read(profileDataSourceProvider);
      String? newAvatarUrl;

      if (_pickedImage != null) {
        newAvatarUrl = await ds.uploadAvatar(_pickedImage!);
      }

      final currentName = switch (ref.read(authControllerProvider).valueOrNull) {
        AuthAuthenticated(:final user) => user.name,
        _ => '',
      };

      final nameChanged = name != currentName;

      if (nameChanged) await ds.updateDisplayName(name);

      await ref.read(authControllerProvider.notifier).updateUserProfile(
            displayName: nameChanged ? name : null,
            avatarUrl: newAvatarUrl,
          );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = 'Lưu thất bại. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authControllerProvider).valueOrNull;

    final (currentName, currentAvatarUrl) = switch (authState) {
      AuthAuthenticated(:final user) => (user.name, user.avatarUrl),
      _ => ('', null),
    };

    final initials = _initials(currentName);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        title: Text('Chỉnh sửa hồ sơ', style: textTheme.titleMedium),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: palette.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: NingyouSpacing.sm),
            child: TextButton(
              onPressed: _isSaving ? null : _save,
              child: Text(
                _isSaving ? 'Đang lưu...' : 'Lưu',
                style: textTheme.bodyMedium?.copyWith(
                  color: _isSaving ? palette.textMuted : palette.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: NingyouSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: NingyouSpacing.xxl),

            // ── Avatar picker ─────────────────────────────────────────────
            GestureDetector(
              onTap: _isSaving ? null : _pickImage,
              child: Stack(
                children: [
                  _pickedImage != null
                      ? ClipOval(
                          child: Image.file(
                            File(_pickedImage!.path),
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        )
                      : NingyouAvatar(
                          initials: initials,
                          imageUrl: currentAvatarUrl,
                          size: NingyouAvatarSize.xl,
                          gradient: NingyouAvatarGradient.blue,
                        ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: palette.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: palette.background, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: palette.onAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: NingyouSpacing.xs),

            Text(
              'Chạm để thay đổi ảnh',
              style: textTheme.bodySmall?.copyWith(color: palette.textSubtle),
            ),

            const SizedBox(height: NingyouSpacing.xxl),

            // ── Error ─────────────────────────────────────────────────────
            if (_error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(NingyouSpacing.sm),
                decoration: BoxDecoration(
                  color: palette.dangerSoft,
                  borderRadius: BorderRadius.circular(NingyouRadius.md),
                ),
                child: Text(
                  _error!,
                  style: textTheme.bodySmall?.copyWith(color: palette.danger),
                ),
              ),
              const SizedBox(height: NingyouSpacing.md),
            ],

            // ── Display name ──────────────────────────────────────────────
            NingyouTextField(
              label: 'TÊN HIỂN THỊ',
              controller: _nameController,
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _isSaving ? null : _save(),
            ),

            const SizedBox(height: NingyouSpacing.xxl),

            // ── Save button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: NingyouButton.primary(
                label: _isSaving ? 'Đang lưu...' : 'Lưu thay đổi',
                onPressed: _isSaving ? null : _save,
                size: NingyouButtonSize.lg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return parts.first[0].toUpperCase();
  }
}
