import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  final _nameError = ValueNotifier<String?>( null);
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
    bool ok = true;
    if (_nameCtrl.text.trim().length < 2) {
      _nameError.value = 'Tên phải có ít nhất 2 ký tự';
      ok = false;
    } else {
      _nameError.value = null;
    }
    if (_descCtrl.text.trim().length < 10) {
      _descError.value = 'Mô tả phải có ít nhất 10 ký tự';
      ok = false;
    } else {
      _descError.value = null;
    }
    if (_promptCtrl.text.trim().length < 20) {
      _promptError.value = 'System prompt phải có ít nhất 20 ký tự';
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

  Future<void> _submit() async {
    if (!_validate() || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final character = await ref
          .read(characterListProvider.notifier)
          .createCharacter(
            name: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            systemPrompt: _promptCtrl.text.trim(),
            greeting: _greetingCtrl.text.trim().isEmpty
                ? null
                : _greetingCtrl.text.trim(),
            traits: List.from(_traits),
            visibility: _visibility,
          );

      if (!mounted) return;

      if (character != null) {
        Navigator.of(context).pop(character);
      } else {
        _showError('Tạo nhân vật thất bại. Thử lại nhé.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(palette: palette),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  NingyouSpacing.xl,
                  NingyouSpacing.lg,
                  NingyouSpacing.xl,
                  NingyouSpacing.xxxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    ValueListenableBuilder(
                      valueListenable: _nameError,
                      builder: (_, err, _) => NingyouTextField(
                        label: 'TÊN NHÂN VẬT',
                        hintText: 'Ví dụ: Hana, Levi, Zero Two...',
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
                        label: 'MÔ TẢ',
                        hintText:
                            'Giới thiệu ngắn về nhân vật — sẽ hiển thị trên card...',
                        controller: _descCtrl,
                        errorText: err,
                        minLines: 3,
                        maxLines: 5,
                      ),
                    ),
                    const SizedBox(height: NingyouSpacing.xl),

                    // System prompt
                    ValueListenableBuilder(
                      valueListenable: _promptError,
                      builder: (_, err, _) => NingyouTextArea(
                        label: 'SYSTEM PROMPT',
                        hintText:
                            'Hướng dẫn AI đóng vai nhân vật này. Mô tả tính cách, cách nói chuyện, phong cách trả lời...',
                        controller: _promptCtrl,
                        errorText: err,
                        helperText: err == null
                            ? 'AI sẽ dựa vào đây để trả lời — càng chi tiết càng tốt'
                            : null,
                        minLines: 5,
                        maxLines: 12,
                      ),
                    ),
                    const SizedBox(height: NingyouSpacing.xl),

                    // Greeting
                    NingyouTextArea(
                      label: 'LỜI CHÀO MỞ ĐẦU (tuỳ chọn)',
                      hintText: 'Tin nhắn đầu tiên nhân vật sẽ gửi...',
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
                    NingyouButton.primary(
                      label: _isSubmitting ? 'Đang tạo...' : 'Tạo nhân vật',
                      icon: Icons.auto_awesome_rounded,
                      size: NingyouButtonSize.lg,
                      onPressed: _isSubmitting ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({required this.palette});

  final NingyouPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NingyouSpacing.md,
        NingyouSpacing.sm,
        NingyouSpacing.xl,
        NingyouSpacing.sm,
      ),
      child: Row(
        children: [
          NingyouIconButton(
            icon: Icons.close_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: NingyouSpacing.sm),
          Expanded(
            child: Text(
              'Nhân vật mới',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: palette.text),
            ),
          ),
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRAITS (tối đa 5)',
          style: NingyouTextStyles.monoLabel(palette.textSubtle)
              .copyWith(letterSpacing: 0.9),
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
            decoration: InputDecoration(
              hintText: 'Thêm trait, nhấn Enter...',
              hintStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.textSubtle),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NingyouRadius.md),
                borderSide: BorderSide(color: palette.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NingyouRadius.md),
                borderSide: BorderSide(color: palette.border),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: NingyouSpacing.md,
                vertical: NingyouSpacing.sm,
              ),
              isDense: true,
            ),
          ),
        const SizedBox(height: 6),
        Text(
          'Ví dụ: Gentle, Stoic, Mysterious...',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: palette.textMuted),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: palette.accentText),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: palette.accentText,
              ),
            ),
          ],
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HIỂN THỊ',
          style: NingyouTextStyles.monoLabel(palette.textSubtle)
              .copyWith(letterSpacing: 0.9),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _VisOption(
              label: 'Công khai',
              icon: Icons.public_rounded,
              selected: value == 'public',
              palette: palette,
              onTap: () => onChange('public'),
            ),
            const SizedBox(width: NingyouSpacing.sm),
            _VisOption(
              label: 'Riêng tư',
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
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: NingyouSpacing.md,
            vertical: NingyouSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? palette.accentSoft : palette.surface,
            borderRadius: BorderRadius.circular(NingyouRadius.md),
            border: Border.all(
              color: selected ? palette.accent : palette.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? palette.accent : palette.textSubtle,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? palette.accentText : palette.textMuted,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
