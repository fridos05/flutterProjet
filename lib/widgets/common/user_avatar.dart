import 'package:flutter/material.dart';
import 'package:edumanager/models/user.dart';

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
          color: _getRoleColor(user.role, theme).withValues(alpha: 0.3),
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

    if (showStatus && user.isActive) {
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
                color: Colors.green,
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

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildFallback(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getRoleColor(user.role, theme).withValues(alpha: 0.1),
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
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0].substring(0, 2).toUpperCase();
    }
    return 'U';
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

class UserCard extends StatelessWidget {
  final User user;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showStatus;

  const UserCard({
    super.key,
    required this.user,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: UserAvatar(
          user: user,
          size: 50,
          showStatus: showStatus,
        ),
        title: Text(
          user.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.role.displayName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getRoleColor(user.role, theme),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        trailing: trailing ?? (onTap != null 
          ? Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))
          : null),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
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