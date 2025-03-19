import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance/services/authService.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviderr>(
      context,
    ); // Fixed typo in class name
    final user = authProvider.user;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Profile'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildProfileHeader(context, user),
                    SizedBox(height: 24),
                    _buildProfileSection(
                      context: context,
                      title: 'Account',
                      icon: Icons.account_circle,
                      children: [
                        _buildTile(
                          context,
                          leading: Icons.person,
                          title: 'Personal Information',
                          onTap: () {
                            /* Navigate to personal info */
                          },
                        ),
                        _buildTile(
                          context,
                          leading: Icons.security,
                          title: 'Security',
                          onTap: () {
                            /* Navigate to security */
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildProfileSection(
                      context: context,
                      title: 'Preferences',
                      icon: Icons.settings,
                      children: [
                        _buildTile(
                          context,
                          leading: Icons.notifications,
                          title: 'Notifications',
                          onTap: () {
                            /* Navigate to notifications */
                          },
                        ),
                        _buildTile(
                          context,
                          leading: Icons.language,
                          title: 'Language',
                          trailing: 'English',
                          onTap: () {
                            /* Navigate to language settings */
                          },
                        ),
                        _buildTile(
                          context,
                          leading: Icons.attach_money,
                          title: 'Currency',
                          trailing: 'USD',
                          onTap: () {
                            /* Navigate to currency settings */
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildProfileSection(
                      context: context,
                      title: 'About',
                      icon: Icons.info_outline,
                      children: [
                        _buildTile(
                          context,
                          leading: Icons.info,
                          title: 'App Info',
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'MyFinance',
                              applicationVersion: '1.0.0',
                              applicationIcon: Icon(
                                Icons.account_balance_wallet,
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              ),
                              children: [
                                Text('A personal finance tracking application'),
                              ],
                            );
                          },
                        ),
                        _buildTile(
                          context,
                          leading: Icons.help,
                          title: 'Help & Support',
                          onTap: () {
                            /* Navigate to help screen */
                          },
                        ),
                        _buildTile(
                          context,
                          leading: Icons.privacy_tip,
                          title: 'Privacy Policy',
                          onTap: () {
                            /* Navigate to privacy policy */
                          },
                        ),
                        _buildTile(
                          context,
                          leading: Icons.logout,
                          title: 'Logout',
                          titleColor: Colors.red,
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    _buildDeleteAccountButton(context),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'profile-avatar',
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  user?.displayName?.isNotEmpty == true
                      ? user!.displayName![0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'User',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    /* Navigate to edit profile */
                  },
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('Edit Profile'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 22),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData leading,
    required String title,
    String? trailing,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(leading, size: 22, color: Colors.grey[700]),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: titleColor ?? Colors.grey[800],
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              )
            else
              Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                child: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // authProvider.signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: OutlinedButton.icon(
        onPressed: () => _showDeleteAccountDialog(context),
        icon: Icon(Icons.delete_forever, color: Colors.red),
        label: Text('Delete Account'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.withOpacity(0.5)),
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Delete Account'),
            content: Text(
              'Are you sure you want to permanently delete your account? This action cannot be undone.',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Delete Account'),
                onPressed: () {
                  // Implement delete account functionality
                  // authProvider.deleteAccount();
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }
}
