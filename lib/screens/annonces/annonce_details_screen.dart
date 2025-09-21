import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/annonce_service.dart';
import '../../services/auth_service.dart';
import '../../services/message_service.dart';
import '../../utils/theme.dart';
import '../../models/annonce.dart';
import '../../models/user.dart' as app_user;
import '../../models/historique.dart';
import '../../services/historique_service.dart';

class AnnonceDetailsScreen extends StatefulWidget {
  final String annonceId;
  
  const AnnonceDetailsScreen({super.key, required this.annonceId});

  @override
  State<AnnonceDetailsScreen> createState() => _AnnonceDetailsScreenState();
}

class _AnnonceDetailsScreenState extends State<AnnonceDetailsScreen> {
  Annonce? _annonce;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnonceDetails();
  }

  Future<void> _loadAnnonceDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final annonceService = context.read<AnnonceService>();
      final annonce = await annonceService.getAnnonceById(widget.annonceId);
      
      if (annonce != null) {
        setState(() {
          _annonce = annonce;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Détails #une annonce'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _annonce == null
              ? const Center(child: Text('Annonce non trouvée'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Photo placeholder comme dans la maquette
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Informations du document
                      _buildInfoField('Type de document', _annonce!.typeDocument.typeDocumentLabel),
                      const SizedBox(height: 16),
                      _buildInfoField('Nom sur document', _annonce!.titre),
                      const SizedBox(height: 16),
                      _buildInfoField('Date de perte', '${_annonce!.datePerte.day}/${_annonce!.datePerte.month}/${_annonce!.datePerte.year}'),
                      const SizedBox(height: 16),
                      _buildInfoField('Lieu de perte', _annonce!.lieuPerte),
                      const SizedBox(height: 16),
                      _buildInfoField('Description', _annonce!.description),
                      const SizedBox(height: 16),
                      
                      // Bouton pour contacter l'auteur
                      if (_annonce!.userId != context.read<AuthService>().currentUser?.id)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _contactAuthor(_annonce!),
                            icon: const Icon(Icons.contact_phone),
                            label: const Text('Contacter l\'auteur'),
                            style: AppTheme.primaryButtonStyle,
                          ),
                        ),
                    ],
                  ),
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

  Widget _buildInfoField(String label, String value) {
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _contactAuthor(Annonce annonce) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacter l\'auteur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choisissez comment contacter l\'auteur :'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Appeler'),
              onTap: () {
                Navigator.pop(context);
                _appelerAuteur(annonce);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Envoyer un message'),
              onTap: () {
                Navigator.pop(context);
                _envoyerMessage(annonce);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _appelerAuteur(Annonce annonce) async {
    try {
      // Récupérer les informations de l'auteur
      final authService = context.read<AuthService>();
      final currentUser = authService.currentUser;
      
      if (currentUser == null) return;
      
      // Ajouter l'action de contact à l'historique
      try {
        final historiqueService = HistoriqueService();
        await historiqueService.ajouterAction(
          userId: currentUser.id,
          action: TypeAction.contact,
          description: 'Contact téléphonique avec l\'auteur de l\'annonce: ${annonce.titre}',
          details: {'annonceId': annonce.id, 'typeContact': 'telephone'},
        );
      } catch (e) {
        print('Erreur lors de l\'ajout de l\'action à l\'historique: $e');
      }
      
      // Simuler l'appel (dans une vraie app, on utiliserait url_launcher)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appel en cours vers l\'auteur de l\'annonce...'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'appel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _envoyerMessage(Annonce annonce) async {
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envoyer un message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Écrivez votre message à l\'auteur de l\'annonce :'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Votre message...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (messageController.text.trim().isEmpty) return;
              
              try {
                final authService = context.read<AuthService>();
                final messageService = context.read<MessageService>();
                final currentUser = authService.currentUser;
                
                if (currentUser == null) return;
                
                // Envoyer le message
                await messageService.envoyerMessage(
                  expediteurId: currentUser.id,
                  destinataireId: annonce.userId,
                  contenu: messageController.text.trim(),
                  annonceId: annonce.id,
                );
                
                // Ajouter l'action de contact à l'historique
                try {
                  final historiqueService = HistoriqueService();
                  await historiqueService.ajouterAction(
                    userId: currentUser.id,
                    action: TypeAction.contact,
                    description: 'Message envoyé à l\'auteur de l\'annonce: ${annonce.titre}',
                    details: {'annonceId': annonce.id, 'typeContact': 'message'},
                  );
                } catch (e) {
                  print('Erreur lors de l\'ajout de l\'action à l\'historique: $e');
                }
                
                Navigator.pop(context);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message envoyé avec succès !'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de l\'envoi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
