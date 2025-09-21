import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/annonce.dart';
import '../utils/theme.dart';

class AnnonceCard extends StatefulWidget {
  final Annonce annonce;
  final VoidCallback? onTap;
  final bool showActions;

  const AnnonceCard({
    super.key,
    required this.annonce,
    this.onTap,
    this.showActions = true,
  });

  @override
  State<AnnonceCard> createState() => _AnnonceCardState();
}

class _AnnonceCardState extends State<AnnonceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.animationCurve,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.animationCurve,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.onTap ?? () {
                context.go('/annonce/${widget.annonce.id}');
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                decoration: AppTheme.elevatedCardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec photo et statut
                    _buildHeader(),
                    
                    // Contenu principal
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre
                          Text(
                            widget.annonce.titre,
                            style: AppTheme.heading3,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          
                          // Description
                          Text(
                            widget.annonce.description,
                            style: AppTheme.bodyMedium,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          
                          // Informations clés
                          _buildInfoRow(),
                          const SizedBox(height: AppTheme.spacingM),
                          
                          // Actions (si activées)
                          if (widget.showActions) _buildActions(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        gradient: AppTheme.primaryGradient,
      ),
      child: Stack(
        children: [
          // Photo de fond (placeholder)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.document_scanner,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          
          // Badge de statut
          Positioned(
            top: AppTheme.spacingM,
            right: AppTheme.spacingM,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: widget.annonce.statut.statutColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.annonce.statut.statutColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.annonce.statut.statutLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Type de document
          Positioned(
            bottom: AppTheme.spacingM,
            left: AppTheme.spacingM,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.annonce.typeDocument.typeDocumentLabel,
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        // Lieu
        Expanded(
          child: _buildInfoItem(
            icon: Icons.location_on,
            text: widget.annonce.lieuPerte,
            color: AppTheme.infoBlue,
          ),
        ),
        const SizedBox(width: AppTheme.spacingM),
        
        // Date
        Expanded(
          child: _buildInfoItem(
            icon: Icons.calendar_today,
            text: '${widget.annonce.datePerte.day}/${widget.annonce.datePerte.month}/${widget.annonce.datePerte.year}',
            color: AppTheme.warningOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: Text(
            text,
            style: AppTheme.caption.copyWith(
              color: AppTheme.darkGrey,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        // Bouton Voir détails
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.go('/annonce/${widget.annonce.id}');
            },
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('Voir détails'),
            style: AppTheme.primaryButtonStyle.copyWith(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingS),
        
        // Bouton Partager
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              // TODO: Implémenter le partage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité de partage à venir'),
                ),
              );
            },
            icon: const Icon(
              Icons.share,
              color: AppTheme.mediumGrey,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
