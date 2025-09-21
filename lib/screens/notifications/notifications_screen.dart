import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationItem(
            title: 'Nouvelle annonce proche',
            subtitle: 'Une annonce correspondant à vos critères a été publiée',
            icon: Icons.location_on,
            color: Colors.blue,
            time: 'Il y a 2 heures',
            isRead: false,
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            title: 'Vous avez un nouveau message',
            subtitle: 'Quelqu\'un a laissé un message sur votre annonce',
            icon: Icons.message,
            color: Colors.green,
            time: 'Il y a 1 jour',
            isRead: true,
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            title: 'Annonce validée',
            subtitle: 'Votre annonce a été validée par l\'équipe',
            icon: Icons.check_circle,
            color: Colors.orange,
            time: 'Il y a 2 jours',
            isRead: true,
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            title: 'Document retrouvé',
            subtitle: 'Félicitations ! Votre document a été retrouvé',
            icon: Icons.celebration,
            color: Colors.purple,
            time: 'Il y a 3 jours',
            isRead: true,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Notifications sélectionné
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Annonces',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/my-annonces');
              break;
            case 2:
              context.go('/notifications');
              break;
          }
        },
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String time,
    required bool isRead,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey[300]! : color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
