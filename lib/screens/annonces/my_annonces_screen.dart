import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/annonce_service.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';
import '../../models/annonce.dart';
import '../../widgets/annonce_card.dart';

class MyAnnoncesScreen extends StatefulWidget {
  const MyAnnoncesScreen({super.key});

  @override
  State<MyAnnoncesScreen> createState() => _MyAnnoncesScreenState();
}

class _MyAnnoncesScreenState extends State<MyAnnoncesScreen> {
  List<Annonce> _myAnnonces = [];
  bool _isLoading = false;
  String _selectedFilter = 'all'; // all, pending, validated, found

  @override
  void initState() {
    super.initState();
    _loadMyAnnonces();
  }

  Future<void> _loadMyAnnonces() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();
      final annonceService = context.read<AnnonceService>();
      
      if (authService.currentUser != null) {
        final annonces = await annonceService.getAnnoncesByUser(authService.currentUser!.id);
        setState(() {
          _myAnnonces = annonces;
        });
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Annonce> get _filteredAnnonces {
    switch (_selectedFilter) {
      case 'pending':
        return _myAnnonces.where((a) => a.statut == StatutAnnonce.perdu).toList();
      case 'validated':
        return _myAnnonces.where((a) => a.statut == StatutAnnonce.enRecherche).toList();
      case 'found':
        return _myAnnonces.where((a) => a.statut == StatutAnnonce.trouve).toList();
      default:
        return _myAnnonces;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mes annonces'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyAnnonces,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres de statut
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip(
                    title: 'En attente',
                    icon: Icons.error_outline,
                    color: Colors.orange,
                    isSelected: _selectedFilter == 'pending',
                    onTap: () => setState(() => _selectedFilter = 'pending'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterChip(
                    title: 'Validée',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    isSelected: _selectedFilter == 'validated',
                    onTap: () => setState(() => _selectedFilter = 'validated'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterChip(
                    title: 'Retrouvée',
                    icon: Icons.add_circle,
                    color: Colors.blue,
                    isSelected: _selectedFilter == 'found',
                    onTap: () => setState(() => _selectedFilter = 'found'),
                  ),
                ),
              ],
            ),
          ),

          // Liste des annonces
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAnnonces.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.list_alt,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune annonce',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vous n\'avez pas encore créé d\'annonces',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/declare-loss'),
                              icon: const Icon(Icons.add),
                              label: const Text('Créer une annonce'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMyAnnonces,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAnnonces.length,
                          itemBuilder: (context, index) {
                            final annonce = _filteredAnnonces[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Stack(
                                children: [
                                  AnnonceCard(annonce: annonce),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          // TODO: Implémenter l'édition
                                        } else if (value == 'delete') {
                                          _deleteAnnonce(annonce.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('Modifier'),
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
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Annonces sélectionné
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

  Widget _buildFilterChip({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAnnonce(String annonceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'annonce'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette annonce ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final annonceService = context.read<AnnonceService>();
                await annonceService.deleteAnnonce(annonceId);
                _loadMyAnnonces(); // Recharger la liste
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
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
