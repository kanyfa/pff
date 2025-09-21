import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/annonce_service.dart';
import '../../utils/theme.dart';
import '../../models/annonce.dart';
import '../../widgets/annonce_card.dart';

class SearchAnnonceScreen extends StatefulWidget {
  const SearchAnnonceScreen({super.key});

  @override
  State<SearchAnnonceScreen> createState() => _SearchAnnonceScreenState();
}

class _SearchAnnonceScreenState extends State<SearchAnnonceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _nomController = TextEditingController();
  final _dateController = TextEditingController();
  final _lieuController = TextEditingController();
  
  List<Annonce> _annonces = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _typeController.dispose();
    _nomController.dispose();
    _dateController.dispose();
    _lieuController.dispose();
    super.dispose();
  }

  Future<void> _searchAnnonces() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final annonceService = context.read<AnnonceService>();
      final annonces = await annonceService.searchAnnonces(
        query: _nomController.text.trim().isNotEmpty ? _nomController.text.trim() : null,
        // lieuPerte: _lieuController.text.trim().isNotEmpty ? _lieuController.text.trim() : null,
      );
      
      setState(() {
        _annonces = annonces;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Recherche d\'annonce'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Column(
        children: [
          // Formulaire de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Type de document
                  _buildSearchField(
                    controller: _typeController,
                    label: 'Type de document',
                    hint: 'Sélectionner un type',
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                  const SizedBox(height: 16),
                  
                  // Nom inscrit
                  _buildSearchField(
                    controller: _nomController,
                    label: 'Nom inscrit',
                    hint: 'Entrer le nom',
                  ),
                  const SizedBox(height: 16),
                  
                  // Date de perte
                  _buildSearchField(
                    controller: _dateController,
                    label: 'Date de perte',
                    hint: 'Sélectionner une date',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lieu de perte
                  _buildSearchField(
                    controller: _lieuController,
                    label: 'Lieu de perte',
                    hint: 'Entrer le lieu',
                  ),
                  const SizedBox(height: 24),
                  
                  // Bouton de recherche
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _searchAnnonces,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Rechercher',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Résultats
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _annonces.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune annonce trouvée',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _annonces.length,
                        itemBuilder: (context, index) {
                          final annonce = _annonces[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AnnonceCard(annonce: annonce),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Accueil sélectionné
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

  Widget _buildSearchField({
    required TextEditingController controller,
    required String label,
    required String hint,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
