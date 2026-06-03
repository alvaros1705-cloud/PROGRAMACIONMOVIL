import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final List<Color> colors;
  final TextAlign? textAlign;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.colors = AppColors.gradient1,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final double blur;
  final Color? borderColor;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.blur = 10,
    this.borderColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color ??
                (isDark
                    ? AppColors.cardDark.withOpacity(0.8)
                    : AppColors.cardLight.withOpacity(0.9)),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ??
                  (isDark ? AppColors.border2Dark : AppColors.border2Light),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final List<Color> colors;
  final double? width;
  final bool isOutlined;
  final Widget? icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.colors = AppColors.gradient1,
    this.width,
    this.isOutlined = false,
    this.icon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.width ?? double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: widget.isOutlined
                ? null
                : LinearGradient(
                    colors: widget.colors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            border: widget.isOutlined
                ? Border.all(color: widget.colors[0], width: 1.5)
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: widget.colors[0].withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 10),
              ],
              Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedOrb extends StatefulWidget {
  final Color color;
  final double size;
  final Duration delay;
  final Alignment alignment;

  const AnimatedOrb({
    super.key,
    required this.color,
    required this.size,
    required this.alignment,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends State<AnimatedOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Align(
          alignment: widget.alignment,
          child: Transform.translate(
            offset: Offset(0, -30 * _anim.value),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class OrbsBackground extends StatelessWidget {
  const OrbsBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOrb(
          color: AppColors.accent,
          size: 400,
          alignment: const Alignment(-1.2, -1.2),
          delay: Duration.zero,
        ),
        AnimatedOrb(
          color: AppColors.accent3,
          size: 350,
          alignment: const Alignment(1.2, 1.2),
          delay: const Duration(seconds: 3),
        ),
        AnimatedOrb(
          color: AppColors.accent5,
          size: 280,
          alignment: const Alignment(0.0, 0.0),
          delay: const Duration(seconds: 6),
        ),
      ],
    );
  }
}

class PulsingLogo extends StatefulWidget {
  final double size;
  const PulsingLogo({super.key, this.size = 72});

  @override
  State<PulsingLogo> createState() => _PulsingLogoState();
}

class _PulsingLogoState extends State<PulsingLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.gradient1,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(widget.size * 0.3),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(_glow.value),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Text('🧘', style: TextStyle(fontSize: 32)),
          ),
        );
      },
    );
  }
}
