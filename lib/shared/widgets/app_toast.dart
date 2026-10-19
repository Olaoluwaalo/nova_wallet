import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';

enum ToastType { success, error, warning, info }

/// Custom overlay toast. One toast at a time: showing a new one replaces the
/// current one.
class AppToast {
  AppToast._();

  static OverlayEntry? _current;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    ToastType type = ToastType.info,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final overlay = _resolveOverlay(context);
    if (overlay == null) return;

    _clear();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastView(
        type: type,
        title: title,
        message: message,
        icon: icon,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismissed: () {
          if (identical(_current, entry)) _clear();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }

  static void success(BuildContext context, String message, {String? title}) =>
      show(context, message: message, title: title, type: ToastType.success);

  static void error(
    BuildContext context,
    String message, {
    String? title,
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      show(
        context,
        message: message,
        title: title,
        type: ToastType.error,
        actionLabel: actionLabel,
        onAction: onAction,
      );

  static void warning(
    BuildContext context,
    String message, {
    String? title,
    IconData? icon,
  }) =>
      show(
        context,
        message: message,
        title: title,
        type: ToastType.warning,
        icon: icon,
      );

  static void info(BuildContext context, String message, {String? title}) =>
      show(context, message: message, title: title, type: ToastType.info);

  static void dismiss() => _clear();

  static OverlayState? _resolveOverlay(BuildContext context) {
    final root = Overlay.maybeOf(context, rootOverlay: true);
    if (root != null) return root;
    return Navigator.maybeOf(context, rootNavigator: true)?.overlay;
  }

  static void _clear() {
    final e = _current;
    _current = null;
    if (e != null) {
      e.remove();
      e.dispose();
    }
  }
}

class _ToastStyle {
  const _ToastStyle({
    required this.background,
    required this.border,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final IconData icon;

  static _ToastStyle of(ToastType type) {
    return switch (type) {
      ToastType.success => const _ToastStyle(
        background: AppColors.successTint,
        border: AppColors.successBorder,
        foreground: AppColors.success,
        icon: Icons.check_circle_outline_rounded,
      ),
      ToastType.error => const _ToastStyle(
        background: AppColors.errorTint,
        border: AppColors.errorBorder,
        foreground: AppColors.error,
        icon: Icons.error_outline_rounded,
      ),
      ToastType.warning => const _ToastStyle(
        background: AppColors.warningTint,
        border: AppColors.warningBorder,
        foreground: AppColors.warning,
        icon: Icons.warning_amber_rounded,
      ),
      ToastType.info => const _ToastStyle(
        background: AppColors.primaryTint,
        border: AppColors.border,
        foreground: AppColors.primary,
        icon: Icons.info_outline_rounded,
      ),
    };
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.type,
    required this.message,
    required this.duration,
    required this.onDismissed,
    this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final ToastType type;
  final String? title;
  final String message;
  final IconData? icon;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismissed;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    reverseDuration: const Duration(milliseconds: 220),
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  Timer? _timer;
  bool _started = false;
  bool _closing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final a11y = MediaQuery.accessibleNavigationOf(context);
    final duration = a11y ? widget.duration * 2 : widget.duration;

    _controller.forward();
    _timer = Timer(duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    if (mounted) await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _ToastStyle.of(widget.type);
    final hasAction = widget.actionLabel != null && widget.onAction != null;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _fade,
                  child: Semantics(
                    liveRegion: true,
                    container: true,
                    onDismiss: _dismiss,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _dismiss,
                      onVerticalDragEnd: (d) {
                        if ((d.primaryVelocity ?? 0) < -120) _dismiss();
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: style.background,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: style.border),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F101828),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 36.w,
                                height: 36.w,
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.icon ?? style.icon,
                                  size: 20.sp,
                                  color: style.foreground,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.title != null)
                                      Text(
                                        widget.title!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.textSmSemibold.copyWith(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    Text(
                                      widget.message,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: widget.title != null
                                          ? AppTextStyles.textXsRegular.copyWith(
                                              color: AppColors.textSecondary,
                                            )
                                          : AppTextStyles.textSmMedium.copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              if (hasAction) ...[
                                SizedBox(width: 8.w),
                                TextButton(
                                  onPressed: () {
                                    widget.onAction!();
                                    _dismiss();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: style.foreground,
                                    minimumSize: const Size(
                                      kMinInteractiveDimension,
                                      kMinInteractiveDimension,
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                                  ),
                                  child: Text(
                                    widget.actionLabel!,
                                    style: AppTextStyles.textXsSemibold.copyWith(
                                      color: style.foreground,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
