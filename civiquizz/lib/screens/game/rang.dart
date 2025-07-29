import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/url.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RangScreen extends StatefulWidget {
  const RangScreen({Key? key}) : super(key: key);

  @override
  State<RangScreen> createState() => _RangScreenState();
}

class _RangScreenState extends State<RangScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<PlayerRank> _allPlayers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRankings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRankings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse(Url.getAllUsers),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> usersData = responseData['data'] ?? [];
        
        setState(() {
          _allPlayers = usersData.map((userData) => PlayerRank.fromJson(userData)).toList();
          _allPlayers.sort((a, b) => _getBadgeRank(b.topBadge).compareTo(_getBadgeRank(a.topBadge)));
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des classements';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion';
        _isLoading = false;
      });
    }
  }

  int _getBadgeRank(String badge) {
    switch (badge.toLowerCase()) {
      case 'maître constitutionnel':
        return 6;
      case 'expert juridique':
        return 5;
      case 'citoyen éclairé':
        return 4;
      case 'apprenti civique':
        return 3;
      case 'novice':
        return 2;
      case 'débutant':
        return 1;
      default:
        return 0;
    }
  }

  Color _getBadgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'maître constitutionnel':
        return const Color(0xFFFFD700); // Gold
      case 'expert juridique':
        return const Color(0xFFC0C0C0); // Silver
      case 'citoyen éclairé':
        return const Color(0xFFCD7F32); // Bronze
      case 'apprenti civique':
        return const Color(0xFF4CAF50); // Green
      case 'novice':
        return const Color(0xFF2196F3); // Blue
      case 'débutant':
        return const Color(0xFF9E9E9E); // Grey
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _getBadgeIcon(String badge) {
    switch (badge.toLowerCase()) {
      case 'maître constitutionnel':
        return Icons.emoji_events;
      case 'expert juridique':
        return Icons.school;
      case 'citoyen éclairé':
        return Icons.lightbulb;
      case 'apprenti civique':
        return Icons.trending_up;
      case 'novice':
        return Icons.star;
      case 'débutant':
        return Icons.play_arrow;
      default:
        return Icons.person;
    }
  }

  List<PlayerRank> _getPlayersByBadge(String badge) {
    return _allPlayers.where((player) => player.topBadge.toLowerCase() == badge.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        title: Text(
          'Classements',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRankings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Général'),
            Tab(text: 'Maîtres'),
            Tab(text: 'Experts'),
            Tab(text: 'Citoyens'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRankings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E3A8A),
                        ),
                        child: Text(
                          'Réessayer',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralRanking(),
                    _buildBadgeRanking('Maître Constitutionnel'),
                    _buildBadgeRanking('Expert Juridique'),
                    _buildBadgeRanking('Citoyen Éclairé'),
                  ],
                ),
    );
  }

  Widget _buildGeneralRanking() {
    if (_allPlayers.isEmpty) {
      return _buildEmptyState('Aucun joueur trouvé');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allPlayers.length,
      itemBuilder: (context, index) {
        final player = _allPlayers[index];
        final rank = index + 1;
        return _buildPlayerCard(player, rank, showBadge: true);
      },
    );
  }

  Widget _buildBadgeRanking(String badge) {
    final players = _getPlayersByBadge(badge);
    
    if (players.isEmpty) {
      return _buildEmptyState('Aucun joueur avec le badge "$badge"');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final rank = index + 1;
        return _buildPlayerCard(player, rank, showBadge: false);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(PlayerRank player, int rank, {bool showBadge = true}) {
    final isCurrentUser = Provider.of<AuthProvider>(context, listen: false).user?.email == player.email;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser 
            ? Border.all(color: Colors.white.withOpacity(0.3), width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          player.pseudo,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Vous',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${player.score} points',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      if (showBadge) ...[
                        const SizedBox(width: 16),
                        Icon(
                          _getBadgeIcon(player.topBadge),
                          color: _getBadgeColor(player.topBadge),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          player.topBadge,
                          style: GoogleFonts.poppins(
                            color: _getBadgeColor(player.topBadge),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF4CAF50); // Green
    }
  }
}

class PlayerRank {
  final String id;
  final String pseudo;
  final String email;
  final int score;
  final int niveau;
  final List<String> badges;
  final String topBadge;

  PlayerRank({
    required this.id,
    required this.pseudo,
    required this.email,
    required this.score,
    required this.niveau,
    required this.badges,
    required this.topBadge,
  });

  factory PlayerRank.fromJson(Map<String, dynamic> json) {
    final badges = (json['badges'] as List<dynamic>?)?.cast<String>() ?? ['Débutant'];
    final topBadge = badges.isNotEmpty ? badges.last : 'Débutant';
    
    return PlayerRank(
      id: json['id']?.toString() ?? '',
      pseudo: json['spseudo'] ?? json['pseudo'] ?? 'Joueur',
      email: json['email'] ?? '',
      score: json['score'] ?? 0,
      niveau: json['niveau'] ?? json['level'] ?? 1,
      badges: badges,
      topBadge: topBadge,
    );
  }
}