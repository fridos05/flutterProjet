import 'package:flutter/material.dart';
import 'package:edumanager/models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final User user;
  final double size;
  final bool showStatus;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.user,
    this.size = 50,
    this.showStatus = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _getRoleColor(user.role, theme).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: user.avatar != null
            ? Image.network(
                user.avatar!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallback(theme),
              )
            : _buildFallback(theme),
      ),
    );

    if (showStatus) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: user.isActive ? Colors.green : Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return onTap != null ? GestureDetector(onTap: onTap, child: avatar) : avatar;
  }

  Widget _buildFallback(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getRoleColor(user.role, theme).withOpacity(0.1),
      ),
      child: Center(
        child: Text(
          _getInitials(user.name),
          style: theme.textTheme.titleMedium?.copyWith(
            color: _getRoleColor(user.role, theme),
            fontWeight: FontWeight.bold,
            fontSize: size * 0.3,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) return '${words[0][0]}${words[1][0]}'.toUpperCase();
    return words.isNotEmpty ? words[0].substring(0, 2).toUpperCase() : 'U';
  }

  Color _getRoleColor(UserRole role, ThemeData theme) {
    switch (role) {
      case UserRole.parent:
        return theme.colorScheme.primary;
      case UserRole.teacher:
        return theme.colorScheme.secondary;
      case UserRole.student:
        return theme.colorScheme.tertiary;
      case UserRole.witness:
        return Colors.grey;
      case UserRole.admin:
        return Colors.purple;
    }
  }
}
