import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/config/themes/app_color.dart';



Future<bool?> showDeleteConfirmationDialog({
  required BuildContext context,
  String title = 'Delete Record?',
  String description =
      'This record will be permanently deleted and cannot be recovered.',
  String confirmLabel = 'Delete',
  String cancelLabel = 'Cancel',
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (_) => DeleteConfirmationDialog(
      title: title,
      description: description,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
  );
}

class DeleteConfirmationDialog extends StatefulWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss(bool result) async {
    await _controller.reverse();
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: _DialogCard(
            title: widget.title,
            description: widget.description,
            confirmLabel: widget.confirmLabel,
            cancelLabel: widget.cancelLabel,
            onConfirm: () => _dismiss(true),
            onCancel: () => _dismiss(false),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Internal card widget
// ─────────────────────────────────────────────
class _DialogCard extends StatelessWidget {
  const _DialogCard({
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    required this.onCancel,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColor.border.withOpacity(0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon area ──────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                decoration: BoxDecoration(
                  color: AppColor.errorLight.withOpacity(0.35),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AppColor.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 34,
                        color: AppColor.error,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Text content ───────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: AppColor.textMuted,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // ── Divider ────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Divider(color: AppColor.divider, height: 24),
              ),

              // ── Buttons ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: _OutlineButton(
                        label: cancelLabel,
                        onTap: onCancel,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Delete
                    Expanded(
                      child: _FilledButton(
                        label: confirmLabel,
                        onTap: onConfirm,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Button sub-widgets
// ─────────────────────────────────────────────
class _OutlineButton extends StatefulWidget {
  const _OutlineButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        decoration: BoxDecoration(
          color: _pressed ? AppColor.divider : AppColor.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.border, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FilledButton extends StatefulWidget {
  const _FilledButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_FilledButton> createState() => _FilledButtonState();
}

class _FilledButtonState extends State<_FilledButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        decoration: BoxDecoration(
          color: _pressed ? AppColor.errorLight : AppColor.error,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: AppColor.error.withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _pressed ? AppColor.error : AppColor.white,
          ),
        ),
      ),
    );
  }
}
