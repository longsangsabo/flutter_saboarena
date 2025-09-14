const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Import additional modules
const { FieldValue } = require("firebase-admin/firestore");

// =============================================================================
// 🎱 SABO ARENA ENHANCED CLOUD FUNCTIONS
// =============================================================================

// -----------------------------------------------------------------------------
// 🔐 USER MANAGEMENT FUNCTIONS
// -----------------------------------------------------------------------------

/**
 * Creates user profile when new user signs up
 */
exports.onUserCreated = functions
  .region("asia-southeast1")
  .auth.user()
  .onCreate(async (user) => {
    const firestore = admin.firestore();
    const userDoc = {
      uid: user.uid,
      email: user.email,
      display_name: user.displayName || "",
      photo_url: user.photoURL || "",
      phone_number: user.phoneNumber || "",
      full_name: "",
      username: "",
      location: "",
      birth_date: null,
      gender: "",
      
      // Game Statistics - Initial values
      elo_rating: 1200, // Starting ELO rating
      overall_ranking: 0,
      total_matches: 0,
      wins: 0,
      losses: 0,
      draws: 0,
      win_rate: 0.0,
      average_match_duration: 0,
      favorite_game_type: "",
      skill_level: "Beginner",
      
      // Activity & Status
      is_online: true,
      last_active: FieldValue.serverTimestamp(),
      account_status: "Active",
      is_verified: false,
      is_banned: false,
      ban_reason: "",
      
      // Preferences
      preferred_language: "vi",
      notification_settings: {
        match_invites: true,
        tournament_updates: true,
        achievements: true,
        messages: true,
        marketing: false
      },
      privacy_settings: {
        show_online_status: true,
        show_statistics: true,
        allow_challenges: true,
        show_location: false
      },
      
      // Timestamps
      created_time: FieldValue.serverTimestamp(),
      updated_time: FieldValue.serverTimestamp()
    };

    try {
      await firestore.collection("users").doc(user.uid).set(userDoc);
      
      // Initialize player statistics
      await initializePlayerStatistics(user.uid);
      
      console.log(`User profile created for ${user.uid}`);
    } catch (error) {
      console.error("Error creating user profile:", error);
      throw error;
    }
  });

/**
 * Cleanup user data when account is deleted
 */
exports.onUserDeleted = functions
  .region("asia-southeast1")
  .auth.user()
  .onDelete(async (user) => {
    const firestore = admin.firestore();
    const batch = firestore.batch();

    try {
      // Delete user document
      const userRef = firestore.doc(`users/${user.uid}`);
      batch.delete(userRef);

      // Delete user statistics
      const statsQuery = await firestore
        .collection("player_statistics")
        .where("user_id", "==", user.uid)
        .get();
      
      statsQuery.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      // Delete user notifications
      const notificationsQuery = await firestore
        .collection("notifications")
        .where("user_id", "==", user.uid)
        .get();
      
      notificationsQuery.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      // Delete push tokens
      const tokensQuery = await firestore
        .collection("push_tokens")
        .where("user_id", "==", user.uid)
        .get();
      
      tokensQuery.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      console.log(`User data cleaned up for ${user.uid}`);
    } catch (error) {
      console.error("Error deleting user data:", error);
      throw error;
    }
  });

// -----------------------------------------------------------------------------
// 🎯 MATCH MANAGEMENT FUNCTIONS
// -----------------------------------------------------------------------------

/**
 * Processes match completion and updates statistics
 */
exports.onMatchCompleted = functions
  .region("asia-southeast1")
  .firestore.document("matches/{matchId}")
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    
    // Only process if match status changed to completed
    if (beforeData.status !== "Completed" && afterData.status === "Completed") {
      const matchId = context.params.matchId;
      
      try {
        await Promise.all([
          updatePlayerStatistics(afterData),
          updateEloRatings(afterData),
          updateClubStatistics(afterData),
          awardAchievements(afterData),
          sendMatchNotifications(afterData)
        ]);
        
        console.log(`Match ${matchId} processed successfully`);
      } catch (error) {
        console.error(`Error processing match ${matchId}:`, error);
        throw error;
      }
    }
  });

/**
 * Creates a match from a challenge
 */
exports.createMatchFromChallenge = functions
  .region("asia-southeast1")
  .https.onCall(async (data, context) => {
    // Verify user authentication
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { challengeId } = data;
    const firestore = admin.firestore();

    try {
      const challengeDoc = await firestore.doc(`challenges/${challengeId}`).get();
      
      if (!challengeDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Challenge not found');
      }

      const challenge = challengeDoc.data();
      
      if (challenge.status !== "Accepted") {
        throw new functions.https.HttpsError('failed-precondition', 'Challenge not accepted');
      }

      // Create match document
      const matchData = {
        match_id: firestore.collection("matches").doc().id,
        club_id: challenge.club_id,
        player1_id: challenge.challenger_id,
        player2_id: challenge.challenged_id,
        game_type: challenge.game_type,
        match_format: challenge.match_format,
        scheduled_time: challenge.accepted_time,
        status: "Scheduled",
        match_type: "Challenge",
        is_ranked: true,
        stakes: challenge.stakes || 0,
        created_time: FieldValue.serverTimestamp(),
        updated_time: FieldValue.serverTimestamp()
      };

      const matchRef = await firestore.collection("matches").add(matchData);
      
      // Update challenge with resulting match ID
      await challengeDoc.ref.update({
        resulting_match_id: matchRef.id,
        status: "Completed",
        updated_time: FieldValue.serverTimestamp()
      });

      return { matchId: matchRef.id };
    } catch (error) {
      console.error("Error creating match from challenge:", error);
      throw error;
    }
  });

// -----------------------------------------------------------------------------
// 🏆 TOURNAMENT MANAGEMENT FUNCTIONS
// -----------------------------------------------------------------------------

/**
 * Manages tournament registration
 */
exports.registerForTournament = functions
  .region("asia-southeast1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { tournamentId } = data;
    const userId = context.auth.uid;
    const firestore = admin.firestore();

    try {
      const tournamentDoc = await firestore.doc(`tournaments/${tournamentId}`).get();
      
      if (!tournamentDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Tournament not found');
      }

      const tournament = tournamentDoc.data();
      
      // Check if registration is still open
      if (tournament.status !== "Registration" && tournament.status !== "Open") {
        throw new functions.https.HttpsError('failed-precondition', 'Registration closed');
      }

      // Check if tournament is full
      if (tournament.current_participants >= tournament.max_participants) {
        throw new functions.https.HttpsError('failed-precondition', 'Tournament is full');
      }

      // Check if user is already registered
      const existingRegistration = await firestore
        .collection("tournament_participants")
        .where("tournament_id", "==", tournamentId)
        .where("user_id", "==", userId)
        .get();

      if (!existingRegistration.empty) {
        throw new functions.https.HttpsError('already-exists', 'Already registered');
      }

      // Create participant document
      const participantData = {
        tournament_id: tournamentId,
        user_id: userId,
        registration_time: FieldValue.serverTimestamp(),
        status: "Registered",
        seed: tournament.current_participants + 1,
        eliminated_in_round: null,
        final_position: null
      };

      await firestore.collection("tournament_participants").add(participantData);

      // Update tournament participant count
      await tournamentDoc.ref.update({
        current_participants: FieldValue.increment(1),
        updated_time: FieldValue.serverTimestamp()
      });

      // Process entry fee if applicable
      if (tournament.entry_fee > 0) {
        await processEntryFee(userId, tournamentId, tournament.entry_fee);
      }

      return { success: true, message: "Registered successfully" };
    } catch (error) {
      console.error("Error registering for tournament:", error);
      throw error;
    }
  });

/**
 * Starts tournament bracket generation
 */
exports.startTournament = functions
  .region("asia-southeast1")
  .https.onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { tournamentId } = data;
    const firestore = admin.firestore();

    try {
      const tournamentDoc = await firestore.doc(`tournaments/${tournamentId}`).get();
      
      if (!tournamentDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Tournament not found');
      }

      const tournament = tournamentDoc.data();
      
      // Verify minimum participants
      if (tournament.current_participants < 2) {
        throw new functions.https.HttpsError('failed-precondition', 'Not enough participants');
      }

      // Generate tournament bracket
      await generateTournamentBracket(tournamentId, tournament);

      // Update tournament status
      await tournamentDoc.ref.update({
        status: "In Progress",
        start_time: FieldValue.serverTimestamp(),
        current_round: 1,
        updated_time: FieldValue.serverTimestamp()
      });

      return { success: true, message: "Tournament started" };
    } catch (error) {
      console.error("Error starting tournament:", error);
      throw error;
    }
  });

// -----------------------------------------------------------------------------
// 📊 STATISTICS AND RANKING FUNCTIONS
// -----------------------------------------------------------------------------

/**
 * Updates global leaderboards (runs daily)
 */
exports.updateLeaderboards = functions
  .region("asia-southeast1")
  .pubsub.schedule("0 2 * * *") // Daily at 2 AM
  .timeZone("Asia/Ho_Chi_Minh")
  .onRun(async (context) => {
    const firestore = admin.firestore();

    try {
      // Update global ELO leaderboard
      await updateGlobalLeaderboard(firestore, "elo_rating", "Global ELO Rankings");
      
      // Update win rate leaderboard
      await updateGlobalLeaderboard(firestore, "win_rate", "Global Win Rate Rankings");
      
      // Update weekly leaderboards
      await updateWeeklyLeaderboards(firestore);
      
      // Update club-specific leaderboards
      await updateClubLeaderboards(firestore);

      console.log("Leaderboards updated successfully");
    } catch (error) {
      console.error("Error updating leaderboards:", error);
      throw error;
    }
  });

// -----------------------------------------------------------------------------
// 🔔 NOTIFICATION FUNCTIONS
// -----------------------------------------------------------------------------

/**
 * Sends push notifications
 */
exports.sendPushNotification = functions
  .region("asia-southeast1")
  .firestore.document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    
    if (notification.is_sent) {
      return; // Already sent
    }

    try {
      const tokens = await getUserPushTokens(notification.user_id);
      
      if (tokens.length === 0) {
        console.log(`No push tokens found for user ${notification.user_id}`);
        return;
      }

      const message = {
        notification: {
          title: notification.title,
          body: notification.message,
        },
        data: {
          type: notification.type,
          action_url: notification.action_url || "",
          notification_id: context.params.notificationId
        },
        tokens: tokens
      };

      const response = await admin.messaging().sendMulticast(message);
      
      // Update notification as sent
      await snap.ref.update({
        is_sent: true,
        sent_time: FieldValue.serverTimestamp()
      });

      // Clean up invalid tokens
      if (response.failureCount > 0) {
        await cleanupInvalidTokens(response.responses, tokens);
      }

      console.log(`Push notification sent to ${response.successCount} devices`);
    } catch (error) {
      console.error("Error sending push notification:", error);
    }
  });

// -----------------------------------------------------------------------------
// 🛠️ HELPER FUNCTIONS
// -----------------------------------------------------------------------------

/**
 * Initialize player statistics for new user
 */
async function initializePlayerStatistics(userId) {
  const firestore = admin.firestore();
  
  const gameTypes = ["8-ball", "9-ball", "10-ball", "snooker"];
  const batch = firestore.batch();

  gameTypes.forEach(gameType => {
    const statsRef = firestore.collection("player_statistics").doc();
    const statsData = {
      user_id: userId,
      game_type: gameType,
      total_matches: 0,
      wins: 0,
      losses: 0,
      draws: 0,
      win_percentage: 0,
      total_shots: 0,
      successful_shots: 0,
      accuracy_percentage: 0,
      average_shots_per_match: 0,
      breaks_made: 0,
      run_outs: 0,
      highest_run: 0,
      average_match_duration: 0,
      total_fouls: 0,
      foul_rate: 0,
      scratch_count: 0,
      current_win_streak: 0,
      longest_win_streak: 0,
      current_loss_streak: 0,
      last_updated: FieldValue.serverTimestamp()
    };
    
    batch.set(statsRef, statsData);
  });

  await batch.commit();
}

/**
 * Update player statistics after match completion
 */
async function updatePlayerStatistics(matchData) {
  const firestore = admin.firestore();
  
  const players = [matchData.player1_id, matchData.player2_id];
  const batch = firestore.batch();

  for (const playerId of players) {
    const statsRef = firestore
      .collection("player_statistics")
      .where("user_id", "==", playerId)
      .where("game_type", "==", matchData.game_type);
    
    const statsDoc = await statsRef.get();
    
    if (!statsDoc.empty) {
      const doc = statsDoc.docs[0];
      const stats = doc.data();
      
      // Determine if this player won
      const isWinner = matchData.winner_id === playerId;
      const isDraw = !matchData.winner_id;
      
      // Update statistics
      const updates = {
        total_matches: stats.total_matches + 1,
        wins: isWinner ? stats.wins + 1 : stats.wins,
        losses: (!isWinner && !isDraw) ? stats.losses + 1 : stats.losses,
        draws: isDraw ? stats.draws + 1 : stats.draws,
        last_updated: FieldValue.serverTimestamp()
      };
      
      // Calculate new win percentage
      updates.win_percentage = updates.wins / updates.total_matches;
      
      batch.update(doc.ref, updates);
    }
  }

  await batch.commit();
}

/**
 * Calculate and update ELO ratings
 */
async function updateEloRatings(matchData) {
  if (!matchData.is_ranked || !matchData.winner_id) {
    return; // Skip unranked matches or draws
  }

  const firestore = admin.firestore();
  
  // Get current ELO ratings
  const [player1Doc, player2Doc] = await Promise.all([
    firestore.doc(`users/${matchData.player1_id}`).get(),
    firestore.doc(`users/${matchData.player2_id}`).get()
  ]);

  const player1Elo = player1Doc.data().elo_rating || 1200;
  const player2Elo = player2Doc.data().elo_rating || 1200;
  
  // Calculate ELO changes
  const kFactor = 32; // K-factor for rating calculation
  const player1Expected = 1 / (1 + Math.pow(10, (player2Elo - player1Elo) / 400));
  const player2Expected = 1 - player1Expected;
  
  const player1Score = matchData.winner_id === matchData.player1_id ? 1 : 0;
  const player2Score = 1 - player1Score;
  
  const player1Change = Math.round(kFactor * (player1Score - player1Expected));
  const player2Change = Math.round(kFactor * (player2Score - player2Expected));
  
  const newPlayer1Elo = Math.max(100, player1Elo + player1Change);
  const newPlayer2Elo = Math.max(100, player2Elo + player2Change);
  
  // Update ELO ratings
  const batch = firestore.batch();
  
  batch.update(player1Doc.ref, {
    elo_rating: newPlayer1Elo,
    updated_time: FieldValue.serverTimestamp()
  });
  
  batch.update(player2Doc.ref, {
    elo_rating: newPlayer2Elo,
    updated_time: FieldValue.serverTimestamp()
  });
  
  // Store ELO changes in match document
  batch.update(firestore.doc(`matches/${matchData.match_id}`), {
    elo_changes: {
      [matchData.player1_id]: {
        before: player1Elo,
        after: newPlayer1Elo,
        change: player1Change
      },
      [matchData.player2_id]: {
        before: player2Elo,
        after: newPlayer2Elo,
        change: player2Change
      }
    }
  });
  
  await batch.commit();
}

/**
 * Get user push tokens
 */
async function getUserPushTokens(userId) {
  const firestore = admin.firestore();
  
  const tokensQuery = await firestore
    .collection("push_tokens")
    .where("user_id", "==", userId)
    .where("is_active", "==", true)
    .get();
  
  return tokensQuery.docs.map(doc => doc.data().push_token);
}

/**
 * Update global leaderboard
 */
async function updateGlobalLeaderboard(firestore, criteria, name) {
  const usersQuery = await firestore
    .collection("users")
    .where("total_matches", ">=", 5) // Minimum matches required
    .orderBy(criteria, "desc")
    .limit(100)
    .get();
  
  const rankings = usersQuery.docs.map((doc, index) => ({
    rank: index + 1,
    user_id: doc.id,
    username: doc.data().display_name || doc.data().email,
    value: doc.data()[criteria],
    change_from_last: 0 // TODO: Calculate from previous ranking
  }));
  
  const leaderboardData = {
    name: name,
    type: "Global",
    criteria: criteria,
    time_period: "All time",
    min_matches_required: 5,
    rankings: rankings,
    total_players: rankings.length,
    last_updated: FieldValue.serverTimestamp(),
    is_active: true
  };
  
  await firestore
    .collection("leaderboards")
    .doc(`global_${criteria}`)
    .set(leaderboardData);
}
