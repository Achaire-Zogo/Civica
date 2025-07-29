import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/theme_provider.dart';

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({Key? key}) : super(key: key);

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      if (themeProvider.themes.isEmpty) {
        themeProvider.loadThemes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3498DB),
              Color(0xFF2980B9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Choisissez un Thème',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Add seed data button for development
                    IconButton(
                      onPressed: () => _seedData(context),
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Error message
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  if (themeProvider.error != null) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              themeProvider.error!,
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => themeProvider.loadThemes(),
                            icon: const Icon(Icons.refresh, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Liste des thèmes
              Expanded(
                child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    if (themeProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    }

                    if (themeProvider.themes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.quiz_outlined,
                              size: 80,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun thème disponible',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Appuyez sur l\'icône paramètres pour créer des données d\'exemple',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: themeProvider.themes.length,
                      itemBuilder: (context, index) {
                        final theme = themeProvider.themes[index];
                        return _ThemeCard(
                          theme: theme,
                          onTap: () => _navigateToLevels(context, theme),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLevels(BuildContext context, Map<String, dynamic> theme) {
    // Check if theme is active
    if (theme['is_active'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ce thème n\'est pas encore disponible !',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFF39C12),
        ),
      );
      return;
    }

    // For now, show a message that levels integration is coming soon
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Intégration des niveaux en cours de développement. Thème: ${theme['title']}',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF3498DB),
        duration: const Duration(seconds: 3),
      ),
    );
    
    // TODO: Navigate to updated LevelsScreen once it's adapted for backend
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => LevelsScreen(themeData: theme),
    //   ),
    // );
  }

  void _seedData(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Créer des données d\'exemple',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Voulez-vous créer des thèmes et niveaux d\'exemple pour tester l\'application ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
            ),
            child: Text(
              'Créer',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await themeProvider.seedSampleData();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              themeProvider.error ?? 'Données d\'exemple créées avec succès !',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: themeProvider.error != null 
                ? Colors.red 
                : const Color(0xFF27AE60),
          ),
        );
      }
    }
  }
}

class _ThemeCard extends StatelessWidget {
  final Map<String, dynamic> theme;
  final VoidCallback onTap;

  const _ThemeCard({
    Key? key,
    required this.theme,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract theme data with safe defaults
    final String title = theme['title'] ?? 'Thème sans nom';
    final String description = theme['description'] ?? 'Aucune description';
    final String icon = theme['icon'] ?? '📚';
    final String color = theme['color'] ?? '#3498DB';
    final bool isActive = theme['is_active'] ?? false;
    final int levelsCount = theme['levels_count'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF7F8C8D),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        if (!isActive)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF39C12).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Color(0xFFF39C12),
                              size: 20,
                            ),
                          )
                        else
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF3498DB),
                            size: 20,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '$levelsCount niveau${levelsCount > 1 ? 'x' : ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      // Remove # if present and add 0xFF prefix
      String cleanColor = colorString.replaceFirst('#', '');
      if (cleanColor.length == 6) {
        return Color(int.parse('0xFF$cleanColor'));
      }
      return const Color(0xFF3498DB); // Default blue
    } catch (e) {
      return const Color(0xFF3498DB); // Default blue on error
    }
  }
}
