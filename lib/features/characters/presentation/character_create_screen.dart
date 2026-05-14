import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';
import '../../../core/theme/ningyou_text_styles.dart';
import '../../../shared/widgets/ningyou/ningyou_button.dart';
import '../../../shared/widgets/ningyou/ningyou_icon_button.dart';
import '../../../shared/widgets/ningyou/ningyou_text_field.dart';
import 'character_controller.dart';

class CharacterCreateScreen extends ConsumerStatefulWidget {
  const CharacterCreateScreen({super.key});

  @override
  ConsumerState<CharacterCreateScreen> createState() =>
      _CharacterCreateScreenState();
}

class _CharacterCreateScreenState extends ConsumerState<CharacterCreateScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _promptCtrl = TextEditingController();
  final _greetingCtrl = TextEditingController();
  final _traitCtrl = TextEditingController();

  final List<String> _traits = [];
  String _visibility = 'public';
  bool _isSubmitting = false;
  File? _avatarFile;
  final _imagePicker = ImagePicker();

  final _nameError = ValueNotifier<String?>(null);
  final _descError = ValueNotifier<String?>(null);
  final _promptError = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _promptCtrl.dispose();
    _greetingCtrl.dispose();
    _traitCtrl.dispose();
    _nameError.dispose();
    _descError.dispose();
    _promptError.dispose();
    super.dispose();
  }

  bool _validate() {
    final l10n = context.l10n;
    bool ok = true;
    if (_nameCtrl.text.trim().length < 2) {
      _nameError.value = l10n.t('characters.nameValidation');
      ok = false;
    } else {
      _nameError.value = null;
    }
    if (_descCtrl.text.trim().length < 10) {
      _descError.value = l10n.t('characters.descriptionValidation');
      ok = false;
    } else {
      _descError.value = null;
    }
    if (_promptCtrl.text.trim().length < 20) {
      _promptError.value = l10n.t('characters.systemPromptValidation');
      ok = false;
    } else {
      _promptError.value = null;
    }
    return ok;
  }

  void _addTrait(String value) {
    final trait = value.trim().replaceAll(',', '');
    if (trait.isEmpty || _traits.length >= 5 || _traits.contains(trait)) return;
    setState(() => _traits.add(trait));
    _traitCtrl.clear();
  }

  Future<void> _pickAvatar() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_validate() || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(characterListProvider.notifier);
      String? storageId;

      if (_avatarFile != null) {
        final uploadUrl = await notifier.getAvatarUploadUrl();
        if (uploadUrl != null) {
          final dio = Dio();
          final bytes = await _avatarFile!.readAsBytes();

          final contentType = _avatarFile!.path.toLowerCase().endsWith('.png')
              ? 'image/png'
              : 'image/jpeg';

          final uploadRes = await dio.post(
            uploadUrl,
            data: Stream.fromIterable([bytes]),
            options: Options(
              headers: {
                Headers.contentLengthHeader: bytes.length,
                Headers.contentTypeHeader: contentType,
              },
            ),
          );

          if (uploadRes.statusCode == 200 && uploadRes.data != null) {
            storageId = uploadRes.data['storageId'] as String?;
          }
        }
      }

      final character = await notifier.createCharacter(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        systemPrompt: _promptCtrl.text.trim(),
        greeting: _greetingCtrl.text.trim().isEmpty
            ? null
            : _greetingCtrl.text.trim(),
        traits: List.from(_traits),
        visibility: _visibility,
        avatarStorageId: storageId,
      );

      if (!mounted) return;

      if (character != null) {
        Navigator.of(context).pop(character);
      } else {
        _showError(context.l10n.t('characters.createError'));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              NingyouSpacing.xl,
              NingyouSpacing.xl,
              NingyouSpacing.xl,
              NingyouSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Magazine-style Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.t('characters.createTitleTop'),
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  color: palette.textMuted,
                                  height: 0.9,
                                ),
                          ),
                          Text(
                            l10n.t('characters.createTitleBottom'),
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  color: palette.text,
                                  fontStyle: FontStyle.italic,
                                  height: 0.9,
                                ),
                          ),
                        ],
                      ),
                    ),
                    NingyouIconButton(
                      icon: Icons.close_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: NingyouSpacing.xxl),

                // Avatar Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(
                              NingyouRadius.xl,
                            ),
                            border: Border.all(color: palette.border),
                            boxShadow: [
                              BoxShadow(
                                color: palette.accent.withValues(alpha: 0.05),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            image: _avatarFile != null
                                ? DecorationImage(
                                    image: FileImage(_avatarFile!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _avatarFile == null
                              ? Icon(
                                  Icons.add_photo_alternate_rounded,
                                  size: 40,
                                  color: palette.textSubtle,
                                )
                              : null,
                        ),
                        if (_avatarFile != null)
                          Positioned(
                            bottom: -8,
                            right: -8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: palette.accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: palette.background,
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: palette.onAccent,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    l10n.t('characters.avatarOptional'),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: palette.textMuted),
                  ),
                ),
                const SizedBox(height: NingyouSpacing.xxxl),

                // Name
                ValueListenableBuilder(
                  valueListenable: _nameError,
                  builder: (_, err, _) => NingyouTextField(
                    label: l10n.t('characters.nameLabel'),
                    hintText: l10n.t('characters.nameHint'),
                    controller: _nameCtrl,
                    errorText: err,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: NingyouSpacing.xl),

                // Description
                ValueListenableBuilder(
                  valueListenable: _descError,
                  builder: (_, err, _) => NingyouTextArea(
                    label: l10n.t('characters.descriptionLabel'),
                    hintText: l10n.t('characters.descriptionHintShort'),
                    controller: _descCtrl,
                    errorText: err,
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(height: NingyouSpacing.xl),

                // System prompt
                ValueListenableBuilder(
                  valueListenable: _promptError,
                  builder: (_, err, _) => NingyouTextArea(
                    label: l10n.t('characters.systemPromptLabel'),
                    hintText: l10n.t('characters.systemPromptHintLong'),
                    controller: _promptCtrl,
                    errorText: err,
                    helperText: err == null
                        ? l10n.t('characters.systemPromptHelperShort')
                        : null,
                    minLines: 6,
                    maxLines: 14,
                  ),
                ),
                const SizedBox(height: NingyouSpacing.xl),

                // Greeting
                NingyouTextArea(
                  label: l10n.t('characters.greetingLabel'),
                  hintText: l10n.t('characters.greetingHint'),
                  controller: _greetingCtrl,
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: NingyouSpacing.xl),

                // Traits
                _TraitInput(
                  traits: _traits,
                  controller: _traitCtrl,
                  palette: palette,
                  onAdd: _addTrait,
                  onRemove: (t) => setState(() => _traits.remove(t)),
                ),
                const SizedBox(height: NingyouSpacing.xl),

                // Visibility
                _VisibilityPicker(
                  value: _visibility,
                  palette: palette,
                  onChange: (v) => setState(() => _visibility = v),
                ),
                const SizedBox(height: NingyouSpacing.xxl),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: NingyouButton.primary(
                    label: _isSubmitting
                        ? l10n.t('characters.creating')
                        : l10n.t('characters.createAction'),
                    icon: Icons.auto_awesome_rounded,
                    size: NingyouButtonSize.lg,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Trait input ───────────────────────────────────────────────────────────────

class _TraitInput extends StatelessWidget {
  const _TraitInput({
    required this.traits,
    required this.controller,
    required this.palette,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> traits;
  final TextEditingController controller;
  final NingyouPalette palette;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.t('characters.traitsTitle'),
          style: NingyouTextStyles.monoLabel(
            palette.textSubtle,
          ).copyWith(letterSpacing: 0.9),
        ),
        const SizedBox(height: 8),
        if (traits.isNotEmpty) ...[
          Wrap(
            spacing: NingyouSpacing.xs,
            runSpacing: NingyouSpacing.xs,
            children: traits
                .map(
                  (t) => _TraitChip(
                    label: t,
                    palette: palette,
                    onRemove: () => onRemove(t),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: NingyouSpacing.sm),
        ],
        if (traits.length < 5)
          TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            onSubmitted: onAdd,
            onChanged: (v) {
              if (v.endsWith(',')) onAdd(v);
            },
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.text),
            decoration: InputDecoration(
              hintText: l10n.t('characters.tagHint'),
              hintStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: palette.textSubtle),
              filled: true,
              fillColor: palette.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NingyouRadius.md),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NingyouRadius.md),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NingyouRadius.md),
                borderSide: BorderSide(color: palette.accent),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: NingyouSpacing.md,
                vertical: NingyouSpacing.sm,
              ),
              isDense: true,
            ),
          ),
      ],
    );
  }
}

class _TraitChip extends StatelessWidget {
  const _TraitChip({
    required this.label,
    required this.palette,
    required this.onRemove,
  });

  final String label;
  final NingyouPalette palette;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
        border: Border.all(color: palette.accent.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.accentText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: palette.accentText,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Visibility picker ─────────────────────────────────────────────────────────

class _VisibilityPicker extends StatelessWidget {
  const _VisibilityPicker({
    required this.value,
    required this.palette,
    required this.onChange,
  });

  final String value;
  final NingyouPalette palette;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.t('characters.visibilityTitle').toUpperCase(),
          style: NingyouTextStyles.monoLabel(
            palette.textSubtle,
          ).copyWith(letterSpacing: 0.9),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _VisOption(
              label: l10n.t('characters.visibilityPublic'),
              icon: Icons.public_rounded,
              selected: value == 'public',
              palette: palette,
              onTap: () => onChange('public'),
            ),
            const SizedBox(width: NingyouSpacing.sm),
            _VisOption(
              label: l10n.t('characters.visibilityPrivate'),
              icon: Icons.lock_outline_rounded,
              selected: value == 'private',
              palette: palette,
              onTap: () => onChange('private'),
            ),
          ],
        ),
      ],
    );
  }
}

class _VisOption extends StatelessWidget {
  const _VisOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final NingyouPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: NingyouSpacing.md,
            vertical: NingyouSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected ? palette.accentSoft : palette.surface,
            borderRadius: BorderRadius.circular(NingyouRadius.lg),
            border: Border.all(
              color: selected
                  ? palette.accent.withValues(alpha: 0.5)
                  : palette.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: selected ? palette.accent : palette.textSubtle,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected ? palette.accentText : palette.textMuted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
