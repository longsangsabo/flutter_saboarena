import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

/// Database service for interacting with Supabase PostgreSQL database
class SupabaseDatabaseService {
  static final _client = SupabaseConfig.client;

  // =====================================================
  // USER OPERATIONS
  // =====================================================

  /// Get user profile by ID
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Get user profile by auth ID
  static Future<Map<String, dynamic>?> getUserProfileByAuthId(String authId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('auth_id', authId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error getting user profile by auth ID: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _client
          .from('users')
          .update(data)
          .eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  /// Get users leaderboard
  static Future<List<Map<String, dynamic>>> getUsersLeaderboard({
    int limit = 20,
    int offset = 0,
    String orderBy = 'elo_rating',
  }) async {
    try {
      final response = await _client
          .from('users')
          .select('id, username, display_name, photo_url, elo_rating, overall_ranking, wins, losses, win_rate')
          .order(orderBy, ascending: false)
          .range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting users leaderboard: $e');
      return [];
    }
  }

  /// Search users by username or display name
  static Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 10}) async {
    try {
      final response = await _client
          .from('users')
          .select('id, username, display_name, photo_url, elo_rating')
          .or('username.ilike.%$query%,display_name.ilike.%$query%')
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // =====================================================
  // CLUB OPERATIONS
  // =====================================================

  /// Get all public clubs
  static Future<List<Map<String, dynamic>>> getPublicClubs({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('clubs')
          .select('''
            *,
            owner:users!clubs_owner_id_fkey(id, username, display_name, photo_url)
          ''')
          .eq('is_public', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting public clubs: $e');
      return [];
    }
  }

  /// Get club by ID
  static Future<Map<String, dynamic>?> getClub(String clubId) async {
    try {
      final response = await _client
          .from('clubs')
          .select('''
            *,
            owner:users!clubs_owner_id_fkey(id, username, display_name, photo_url)
          ''')
          .eq('id', clubId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error getting club: $e');
      return null;
    }
  }

  /// Create new club
  static Future<String?> createClub(Map<String, dynamic> clubData) async {
    try {
      clubData['created_at'] = DateTime.now().toIso8601String();
      clubData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from('clubs')
          .insert(clubData)
          .select()
          .single();
      return response['id'];
    } catch (e) {
      print('Error creating club: $e');
      return null;
    }
  }

  /// Get club members
  static Future<List<Map<String, dynamic>>> getClubMembers(String clubId) async {
    try {
      final response = await _client
          .from('club_members')
          .select('''
            *,
            user:users!club_members_user_id_fkey(id, username, display_name, photo_url, elo_rating)
          ''')
          .eq('club_id', clubId)
          .eq('status', 'active')
          .order('joined_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting club members: $e');
      return [];
    }
  }

  /// Join club
  static Future<bool> joinClub(String clubId, String userId) async {
    try {
      // Check if club requires approval
      final club = await getClub(clubId);
      if (club == null) return false;

      final status = club['requires_approval'] == true ? 'pending' : 'active';

      await _client.from('club_members').insert({
        'club_id': clubId,
        'user_id': userId,
        'status': status,
        'joined_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error joining club: $e');
      return false;
    }
  }

  // =====================================================
  // TOURNAMENT OPERATIONS
  // =====================================================

  /// Get tournaments
  static Future<List<Map<String, dynamic>>> getTournaments({
    int limit = 20,
    int offset = 0,
    String? clubId,
    String? status,
  }) async {
    try {
      var query = _client
          .from('tournaments')
          .select('''
            *,
            club:clubs!tournaments_club_id_fkey(id, name, logo_url),
            organizer:users!tournaments_organizer_id_fkey(id, username, display_name, photo_url)
          ''');

      if (clubId != null) {
        query = query.eq('club_id', clubId);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query
          .order('tournament_start', ascending: false)
          .range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting tournaments: $e');
      return [];
    }
  }

  /// Get tournament by ID
  static Future<Map<String, dynamic>?> getTournament(String tournamentId) async {
    try {
      final response = await _client
          .from('tournaments')
          .select('''
            *,
            club:clubs!tournaments_club_id_fkey(id, name, logo_url),
            organizer:users!tournaments_organizer_id_fkey(id, username, display_name, photo_url)
          ''')
          .eq('id', tournamentId)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error getting tournament: $e');
      return null;
    }
  }

  /// Create tournament
  static Future<String?> createTournament(Map<String, dynamic> tournamentData) async {
    try {
      tournamentData['created_at'] = DateTime.now().toIso8601String();
      tournamentData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from('tournaments')
          .insert(tournamentData)
          .select()
          .single();
      return response['id'];
    } catch (e) {
      print('Error creating tournament: $e');
      return null;
    }
  }

  /// Register for tournament
  static Future<bool> registerForTournament(String tournamentId, String userId) async {
    try {
      await _client.from('tournament_participants').insert({
        'tournament_id': tournamentId,
        'user_id': userId,
        'registration_date': DateTime.now().toIso8601String(),
        'status': 'registered',
      });
      return true;
    } catch (e) {
      print('Error registering for tournament: $e');
      return false;
    }
  }

  /// Get tournament participants
  static Future<List<Map<String, dynamic>>> getTournamentParticipants(String tournamentId) async {
    try {
      final response = await _client
          .from('tournament_participants')
          .select('''
            *,
            user:users!tournament_participants_user_id_fkey(id, username, display_name, photo_url, elo_rating)
          ''')
          .eq('tournament_id', tournamentId)
          .order('registration_date', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting tournament participants: $e');
      return [];
    }
  }

  // =====================================================
  // MATCH OPERATIONS
  // =====================================================

  /// Get matches
  static Future<List<Map<String, dynamic>>> getMatches({
    int limit = 20,
    int offset = 0,
    String? tournamentId,
    String? playerId,
    String? status,
  }) async {
    try {
      var query = _client
          .from('matches')
          .select('''
            *,
            player1:users!matches_player1_id_fkey(id, username, display_name, photo_url, elo_rating),
            player2:users!matches_player2_id_fkey(id, username, display_name, photo_url, elo_rating),
            winner:users!matches_winner_id_fkey(id, username, display_name, photo_url),
            tournament:tournaments!matches_tournament_id_fkey(id, name),
            club:clubs!matches_club_id_fkey(id, name)
          ''');

      if (tournamentId != null) {
        query = query.eq('tournament_id', tournamentId);
      }

      if (playerId != null) {
        query = query.or('player1_id.eq.$playerId,player2_id.eq.$playerId');
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting matches: $e');
      return [];
    }
  }

  /// Create match
  static Future<String?> createMatch(Map<String, dynamic> matchData) async {
    try {
      matchData['created_at'] = DateTime.now().toIso8601String();
      matchData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from('matches')
          .insert(matchData)
          .select()
          .single();
      return response['id'];
    } catch (e) {
      print('Error creating match: $e');
      return null;
    }
  }

  /// Update match
  static Future<bool> updateMatch(String matchId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await _client
          .from('matches')
          .update(data)
          .eq('id', matchId);
      return true;
    } catch (e) {
      print('Error updating match: $e');
      return false;
    }
  }

  // =====================================================
  // NOTIFICATION OPERATIONS
  // =====================================================

  /// Get user notifications
  static Future<List<Map<String, dynamic>>> getUserNotifications({
    required String userId,
    int limit = 20,
    int offset = 0,
    bool? isRead,
  }) async {
    try {
      var query = _client
          .from('notifications')
          .select()
          .eq('user_id', userId);

      if (isRead != null) {
        query = query.eq('is_read', isRead);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({
            'is_read': true,
            'read_time': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .eq('is_read', false);
      return response.length;
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }

  // =====================================================
  // STATISTICS OPERATIONS
  // =====================================================

  /// Get player statistics
  static Future<Map<String, dynamic>?> getPlayerStatistics({
    required String userId,
    String periodType = 'all_time',
  }) async {
    try {
      final response = await _client
          .from('player_statistics')
          .select()
          .eq('user_id', userId)
          .eq('period_type', periodType)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error getting player statistics: $e');
      return null;
    }
  }

  /// Get leaderboard
  static Future<List<Map<String, dynamic>>> getLeaderboard({
    String leaderboardType = 'elo',
    String periodType = 'all_time',
    String? clubId,
    int limit = 50,
  }) async {
    try {
      var query = _client
          .from('leaderboard_entries')
          .select('''
            *,
            user:users!leaderboard_entries_user_id_fkey(id, username, display_name, photo_url),
            leaderboard:leaderboards!leaderboard_entries_leaderboard_id_fkey(name, description)
          ''');

      // Find the appropriate leaderboard
      final leaderboardQuery = _client
          .from('leaderboards')
          .select('id')
          .eq('leaderboard_type', leaderboardType)
          .eq('period_type', periodType);

      if (clubId != null) {
        leaderboardQuery.eq('club_id', clubId);
      } else {
        leaderboardQuery.isFilter('club_id', null);
      }

      final leaderboard = await leaderboardQuery.maybeSingle();
      if (leaderboard == null) return [];

      final response = await query
          .eq('leaderboard_id', leaderboard['id'])
          .order('rank', ascending: true)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting leaderboard: $e');
      return [];
    }
  }
}