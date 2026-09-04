import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CategoryCard extends StatefulWidget {
  final String title;
  final String iconPath;
  final IconData? fallbackIcon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? bgColor;

  const CategoryCard({
    super.key,
    required this.title,
    required this.iconPath,
    this.fallbackIcon,
    required this.onTap,
    this.iconColor,
    this.bgColor,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.iconColor ?? AppTheme.primaryTeal;
    final bg = widget.bgColor ?? color.withOpacity(0.08);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isHovered ? bg : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered ? color.withOpacity(0.3) : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered ? color.withOpacity(0.15) : Colors.black.withOpacity(0.04),
                  blurRadius: _isHovered ? 16 : 8,
                  offset: Offset(0, _isHovered ? 6 : 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(_isHovered ? 14 : 12),
                  decoration: BoxDecoration(
                    color: _isHovered ? color.withOpacity(0.15) : bg,
                    shape: BoxShape.circle,
                  ),
                  child: widget.fallbackIcon != null
                      ? Icon(widget.fallbackIcon, size: 28, color: color)
                      : Image.asset(widget.iconPath, width: 28, height: 28,
                          errorBuilder: (c, e, s) => Icon(Icons.category, size: 28, color: color)),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: _isHovered ? color : AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
