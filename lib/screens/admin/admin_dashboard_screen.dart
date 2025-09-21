import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';
import '../../models/user.dart' as app_user;
import '../../models/annonce.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  Map<String, dynamic> _statistiques = {};
  List<app_user.User> _utilisateurs = [];
  List<Annonce> _annoncesEnAttente = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _chargerDonnees();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _chargerDonnees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminService = context.read<AdminService>();
      
      // Charger les statistiques
      _statistiques = await adminService.getStatistiquesDetaillees();
      
      // Charger les utilisateurs
      _utilisateurs = await adminService.getAllUsers();
      
      // Charger les annonces en attente
      _annoncesEnAttente = await adminService.getAnnoncesEnAttente();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    
    // Vérifier si l'utilisateur est admin
    if (authService.currentUser == null || !authService.currentUser!.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Accès refusé')),
        body: const Center(
          child: Text(
            'Vous n\'avez pas les permissions nécessaires pour accéder à cette page.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Admin'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _chargerDonnees,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Statistiques'),
            Tab(icon: Icon(Icons.people), text: 'Utilisateurs'),
            Tab(icon: Icon(Icons.description), text: 'Annonces'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStatistiquesTab(),
                _buildUtilisateursTab(),
                _buildAnnoncesTab(),
              ],
            ),
    );
  }

  Widget _buildStatistiquesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            'Vue d\'ensemble',
            [
              _buildStatItem('Total annonces', _statistiques['annonces']?['total']?.toString() ?? '0'),
              _buildStatItem('Annonces perdues', _statistiques['annonces']?['perdues']?.toString() ?? '0'),
              _buildStatItem('Annonces trouvées', _statistiques['annonces']?['trouvees']?.toString() ?? '0'),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Utilisateurs',
            [
              _buildStatItem('Total utilisateurs', _statistiques['utilisateurs']?['total']?.toString() ?? '0'),
              _buildStatItem('Administrateurs', _statistiques['utilisateurs']?['admins']?.toString() ?? '0'),
              _buildStatItem('Utilisateurs normaux', _statistiques['utilisateurs']?['normaux']?.toString() ?? '0'),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Activité récente',
            [
              _buildStatItem('Annonces récentes (7j)', _statistiques['annonces']?['recentes']?.toString() ?? '0'),
              _buildStatItem('Total actions', _statistiques['activite']?['totalActions']?.toString() ?? '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUtilisateursTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _utilisateurs.length,
      itemBuilder: (context, index) {
        final utilisateur = _utilisateurs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: utilisateur.isAdmin ? AppTheme.primaryBlue : Colors.grey,
              child: Text(
                utilisateur.prenom[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text('${utilisateur.prenom} ${utilisateur.nom}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(utilisateur.email),
                Text(
                  'Rôle: ${utilisateur.isAdmin ? 'Administrateur' : 'Utilisateur'}',
                  style: TextStyle(
                    color: utilisateur.isAdmin ? AppTheme.primaryBlue : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _gererUtilisateur(value, utilisateur),
              itemBuilder: (context) => [
                if (!utilisateur.isAdmin)
                  const PopupMenuItem(
                    value: 'make_admin',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings),
                        SizedBox(width: 8),
                        Text('Promouvoir admin'),
                      ],
                    ),
                  ),
                if (utilisateur.isAdmin)
                  const PopupMenuItem(
                    value: 'remove_admin',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove),
                        SizedBox(width: 8),
                        Text('Retirer admin'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnnoncesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _annoncesEnAttente.length,
      itemBuilder: (context, index) {
        final annonce = _annoncesEnAttente[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(annonce.titre),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(annonce.description),
                Text('Type: ${annonce.typeDocument.typeDocumentLabel}'),
                Text('Statut: ${annonce.statut.statutLabel}'),
                Text('Date: ${annonce.dateCreation.toString().split(' ')[0]}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _validerAnnonce(annonce.id),
                  tooltip: 'Valider',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _supprimerAnnonce(annonce.id),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.mediumGrey)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _gererUtilisateur(String action, app_user.User utilisateur) async {
    try {
      final adminService = context.read<AdminService>();
      
      switch (action) {
        case 'make_admin':
          await adminService.modifierRoleUtilisateur(utilisateur.id, 'admin');
          break;
        case 'remove_admin':
          await adminService.modifierRoleUtilisateur(utilisateur.id, 'user');
          break;
        case 'delete':
          await _confirmerSuppressionUtilisateur(utilisateur);
          return;
      }
      
      await _chargerDonnees();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Utilisateur modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmerSuppressionUtilisateur(app_user.User utilisateur) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer l\'utilisateur ${utilisateur.prenom} ${utilisateur.nom} ? '
          'Cette action supprimera également toutes ses annonces.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final adminService = context.read<AdminService>();
        await adminService.supprimerUtilisateur(utilisateur.id);
        await _chargerDonnees();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Utilisateur supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _validerAnnonce(String annonceId) async {
    try {
      final adminService = context.read<AdminService>();
      await adminService.validerAnnonce(annonceId);
      await _chargerDonnees();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Annonce validée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la validation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _supprimerAnnonce(String annonceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette annonce ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final adminService = context.read<AdminService>();
        await adminService.supprimerAnnonceAdmin(annonceId);
        await _chargerDonnees();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Annonce supprimée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}


