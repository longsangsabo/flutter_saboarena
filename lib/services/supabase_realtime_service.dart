import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

/// Real-time service for handling live updates with Supabase Realtime
class SupabaseRealtimeService {
  static final _client = SupabaseConfig.client;
  static final Map<String, RealtimeChannel> _channels = {};

  // =====================================================
  // USER STATUS SUBSCRIPTIONS
  // =====================================================

  /// Subscribe to user status changes (online/offline)
  static RealtimeChannel subscribeToUserStatus(
    String userId,
    Function(Map<String, dynamic>) onUpdate,
  ) {
    final channelName = 'user-status-$userId';
    
    // Remove existing channel if any
    unsubscribe(channelName);
    
    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onUpdate(payload.newRecord);
            }
          },
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }

  // =====================================================
  // MATCH SUBSCRIPTIONS
  // =====================================================

  /// Subscribe to match updates (scores, status changes)
  static RealtimeChannel subscribeToMatch(
    String matchId,
    Function(Map<String, dynamic>) onUpdate,
  ) {
    final channelName = 'match-$matchId';
    
    // Remove existing channel if any
    unsubscribe(channelName);
    
    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'matches',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: matchId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onUpdate(payload.newRecord);
            }
          },
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }

  /// Subscribe to new matches for a user
  static RealtimeChannel subscribeToUserMatches(
    String userId,
    Function(Map<String, dynamic>) onNewMatch,
  ) {
    final channelName = 'user-matches-$userId';
    
    // Remove existing channel if any
    unsubscribe(channelName);
    
    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'matches',
          callback: (payload) {
            if (payload.newRecord != null) {
              final record = payload.newRecord;
              // Check if user is involved in the match
              if (record['player1_id'] == userId || record['player2_id'] == userId) {
                onNewMatch(record);
              }
            }
          },
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }

  // =====================================================
  // TOURNAMENT SUBSCRIPTIONS
  // =====================================================

  /// Subscribe to tournament updates
  static RealtimeChannel subscribeToTournament(
    String tournamentId,
    Function(Map<String, dynamic>) onUpdate,
  ) {
    final channelName = 'tournament-$tournamentId';
    
    // Remove existing channel if any
    unsubscribe(channelName);
    
    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'tournaments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: tournamentId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onUpdate(payload.newRecord);
            }
          },
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }

  /// Subscribe to tournament participants changes
  static RealtimeChannel subscribeToTournamentParticipants(
    String tournamentId,
    Function(Map<String, dynamic>) onParticipantJoin,
    Function(Map<String, dynamic>) onParticipantLeave,
  ) {
    final channelName = 'tournament-participants-$tournamentId';
    
    // Remove existing channel if any
    unsubscribe(channelName);
    
    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'tournament_participants',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tournament_id',
            value: tournamentId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onParticipantJoin(payload.newRecord);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'tournament_participants',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tournament_id',
            value: tournamentId,
          ),
          callback: (payload) {
            if (payload.oldRecord != null) {
              onParticipantLeave(payload.oldRecord);
            }
          },
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }

  // =====================================================
  // CHAT SUBSCRIPTIONS
  // =====================================================

  /// Subscribe to club chat messages
  static RealtimeChannel subscribeToClubChat(
    String clubId,
    Function(Map<String, dynamic>) onNewMessage,
    Function(Map<String, dynamic>) onMessageUpdate,
    Function(Map<String, dynamic>) onMessageDelete,
  ) {
    final channelName = 'club-chat-$clubId';
    
    // Remove existing channel if any
    unsubscribe(channelName);
    
    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'club_id',
            value: clubId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onNewMessage(payload.newRecord);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'club_id',
            value: clubId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onMessageUpdate(payload.newRecord);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'club_id',
            value: clubId,
          ),
          callback: (payload) {
            if (payload.oldRecord != null) {
              onMessageDelete(payload.oldRecord);
            }
          },
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }

  /// Subscribe to tournament chat messages
  static RealtimeChannel subscribeToTournamentChat(
    String tournamentId,
    Function(Map<String, dynamic>) onNewMessage,
  ) {
    final channelName = 'tournament-chat-$tournamentId';
    
    // Remove existing channel if any
    unsubscribe(channelName);
    
    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tournament_id',
            value: tournamentId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onNewMessage(payload.newRecord);
            }
          },
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }

  /// Subscribe to match chat messages
  static RealtimeChannel subscribeToMatchChat(
    String matchId,
    Function(Map<String, dynamic>) onNewMessage,
  ) {
    final channelName = 'match-chat-$matchId';
    
    // Remove existing channel if any
    unsubscribe(channelName);
    
    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: matchId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onNewMessage(payload.newRecord);
            }
          },
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }

  // =====================================================
  // NOTIFICATION SUBSCRIPTIONS
  // =====================================================

  /// Subscribe to user notifications
  static RealtimeChannel subscribeToNotifications(
    String userId,
    Function(Map<String, dynamic>) onNewNotification,
  ) {
    final channelName = 'notifications-$userId';
    
    // Remove existing channel if any
    unsubscribe(channelName);
    
    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onNewNotification(payload.newRecord);
            }
          },
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }

  // =====================================================
  // LEADERBOARD SUBSCRIPTIONS
  // =====================================================

  /// Subscribe to leaderboard updates
  static RealtimeChannel subscribeToLeaderboard(
    String leaderboardId,
    Function(Map<String, dynamic>) onLeaderboardUpdate,
  ) {
    final channelName = 'leaderboard-$leaderboardId';
    
    // Remove existing channel if any
    unsubscribe(channelName);
    
    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'leaderboard_entries',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'leaderboard_id',
            value: leaderboardId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onLeaderboardUpdate(payload.newRecord);
            } else if (payload.oldRecord != null) {
              onLeaderboardUpdate(payload.oldRecord);
            }
          },
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }

  // =====================================================
  // CLUB SUBSCRIPTIONS
  // =====================================================

  /// Subscribe to club member changes
  static RealtimeChannel subscribeToClubMembers(
    String clubId,
    Function(Map<String, dynamic>) onMemberJoin,
    Function(Map<String, dynamic>) onMemberLeave,
    Function(Map<String, dynamic>) onMemberUpdate,
  ) {
    final channelName = 'club-members-$clubId';
    
    // Remove existing channel if any
    unsubscribe(channelName);
    
    final channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'club_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'club_id',
            value: clubId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onMemberJoin(payload.newRecord);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'club_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'club_id',
            value: clubId,
          ),
          callback: (payload) {
            if (payload.oldRecord != null) {
              onMemberLeave(payload.oldRecord);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'club_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'club_id',
            value: clubId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onMemberUpdate(payload.newRecord);
            }
          },
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }

  // =====================================================
  // PRESENCE TRACKING (Simplified)
  // =====================================================

  /// Track user presence
  static RealtimeChannel trackPresence(
    String context,
    String userId,
    Map<String, dynamic> userInfo,
    Function(String, Map<String, dynamic>) onPresenceUpdate,
  ) {
    final channelName = 'presence-$context';
    
    // Remove existing channel if any
    unsubscribe(channelName);
    
    final channel = _client
        .channel(channelName)
        .onPresenceSync((syncs) {
          onPresenceUpdate(context, {'event': 'sync', 'data': syncs});
        })
        .onPresenceJoin((joins) {
          onPresenceUpdate(context, {'event': 'join', 'data': joins});
        })
        .onPresenceLeave((leaves) {
          onPresenceUpdate(context, {'event': 'leave', 'data': leaves});
        })
        .subscribe((status, [error]) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            await channel.track({
              'user_id': userId,
              'online_at': DateTime.now().toIso8601String(),
              ...userInfo,
            });
          }
        });
    
    _channels[channelName] = channel;
    return channel;
  }

  /// Untrack presence
  static Future<void> untrackPresence(String context) async {
    final channelName = 'presence-$context';
    final channel = _channels[channelName];
    if (channel != null) {
      await channel.untrack();
      await channel.unsubscribe();
      _channels.remove(channelName);
    }
  }

  // =====================================================
  // CHANNEL MANAGEMENT
  // =====================================================

  /// Unsubscribe from a specific channel
  static Future<void> unsubscribe(String channelName) async {
    final channel = _channels[channelName];
    if (channel != null) {
      await channel.unsubscribe();
      _channels.remove(channelName);
    }
  }

  /// Unsubscribe from all channels
  static Future<void> unsubscribeAll() async {
    for (final channel in _channels.values) {
      await channel.unsubscribe();
    }
    _channels.clear();
  }

  /// Get all active channels
  static Map<String, RealtimeChannel> get activeChannels => Map.from(_channels);

  /// Check if channel exists
  static bool hasChannel(String channelName) => _channels.containsKey(channelName);

  /// Get channel by name
  static RealtimeChannel? getChannel(String channelName) => _channels[channelName];

  // =====================================================
  // BROADCAST METHODS
  // =====================================================

  /// Send broadcast message to channel
  static Future<void> broadcast(
    String channelName,
    String event,
    Map<String, dynamic> payload,
  ) async {
    final channel = _channels[channelName];
    if (channel != null) {
      await channel.sendBroadcastMessage(
        event: event,
        payload: payload,
      );
    }
  }

  /// Listen to broadcast messages
  static RealtimeChannel listenToBroadcast(
    String channelName,
    String event,
    Function(Map<String, dynamic>) onMessage,
  ) {
    // Remove existing channel if any
    unsubscribe(channelName);
    
    final channel = _client
        .channel(channelName)
        .onBroadcast(
          event: event,
          callback: (payload) {
            onMessage(payload);
          },
        )
        .subscribe();
    
    _channels[channelName] = channel;
    return channel;
  }
}