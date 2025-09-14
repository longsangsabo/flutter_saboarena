import { createClient } from '@supabase/supabase-js'

// Test configuration
const SUPABASE_URL = 'https://skzirkhzwhyqmnfyytcl.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNremlya2h6d2h5cW1uZnl5dGNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3NDM3MzUsImV4cCI6MjA3MzMxOTczNX0._0Ic0SL4FZVMennTXmOzIp2KBOCwRagpbRXaWhZJI24'
const SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNremlya2h6d2h5cW1uZnl5dGNsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Nzc0MzczNSwiZXhwIjoyMDczMzE5NzM1fQ.xIlkzXWPUq6Kwcs__XEduFZnCEi_y4up8Hd536VDmy0'

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

// Test user credentials (use actual test users)
const TEST_USER_EMAIL = 'test@example.com'
const TEST_USER_PASSWORD = 'testpassword123'

async function testCreateMatchFromChallenge() {
  console.log('🧪 Testing create-match-from-challenge function...')
  
  try {
    // Sign in as test user
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: TEST_USER_EMAIL,
      password: TEST_USER_PASSWORD
    })

    if (authError) {
      throw authError
    }

    // Create a test challenge first
    const { data: challenge, error: challengeError } = await supabaseAdmin
      .from('challenges')
      .insert({
        challenger_id: authData.user.id,
        challenged_id: 'test-challenged-user-id',
        club_id: 1,
        game_type: '8-ball',
        match_format: 'Best of 3',
        status: 'Accepted',
        stakes: 10,
        accepted_time: new Date().toISOString()
      })
      .select()
      .single()

    if (challengeError) {
      throw challengeError
    }

    // Call the function
    const { data, error } = await supabase.functions.invoke('create-match-from-challenge', {
      body: { challengeId: challenge.id }
    })

    if (error) {
      throw error
    }

    console.log('✅ Create match from challenge successful:', data)
    return data
  } catch (error) {
    console.error('❌ Create match from challenge failed:', error)
    throw error
  }
}

async function testRegisterTournament() {
  console.log('🧪 Testing register-tournament function...')
  
  try {
    // Sign in as test user
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: TEST_USER_EMAIL,
      password: TEST_USER_PASSWORD
    })

    if (authError) {
      throw authError
    }

    // Create a test tournament first
    const { data: tournament, error: tournamentError } = await supabaseAdmin
      .from('tournaments')
      .insert({
        name: 'Test Tournament',
        description: 'A test tournament',
        club_id: 1,
        organizer_id: 'test-organizer-id',
        game_type: '9-ball',
        tournament_format: 'Single Elimination',
        max_participants: 16,
        min_participants: 8,
        current_participants: 5,
        entry_fee: 20,
        prize_pool: 300,
        status: 'Registration',
        start_time: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // Tomorrow
        end_time: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString(), // 3 days from now
        registration_deadline: new Date(Date.now() + 12 * 60 * 60 * 1000).toISOString() // 12 hours from now
      })
      .select()
      .single()

    if (tournamentError) {
      throw tournamentError
    }

    // Call the function
    const { data, error } = await supabase.functions.invoke('register-tournament', {
      body: { tournamentId: tournament.id }
    })

    if (error) {
      throw error
    }

    console.log('✅ Tournament registration successful:', data)
    return data
  } catch (error) {
    console.error('❌ Tournament registration failed:', error)
    throw error
  }
}

async function testUpdateMatchResult() {
  console.log('🧪 Testing update-match-result function...')
  
  try {
    // Sign in as test user
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: TEST_USER_EMAIL,
      password: TEST_USER_PASSWORD
    })

    if (authError) {
      throw authError
    }

    // Create a test match first
    const { data: match, error: matchError } = await supabaseAdmin
      .from('matches')
      .insert({
        club_id: 1,
        player1_id: authData.user.id,
        player2_id: 'test-player2-id',
        game_type: '8-ball',
        match_format: 'Best of 3',
        status: 'In Progress',
        match_type: 'Tournament',
        is_ranked: true
      })
      .select()
      .single()

    if (matchError) {
      throw matchError
    }

    // Call the function
    const { data, error } = await supabase.functions.invoke('update-match-result', {
      body: { 
        matchId: match.id,
        winnerId: authData.user.id,
        score: '3-1',
        gameDuration: 45
      }
    })

    if (error) {
      throw error
    }

    console.log('✅ Match result update successful:', data)
    return data
  } catch (error) {
    console.error('❌ Match result update failed:', error)
    throw error
  }
}

async function testUpdateLeaderboards() {
  console.log('🧪 Testing update-leaderboards function...')
  
  try {
    // Call the function (doesn't require authentication)
    const { data, error } = await supabase.functions.invoke('update-leaderboards', {
      body: {}
    })

    if (error) {
      throw error
    }

    console.log('✅ Leaderboard update successful:', data)
    return data
  } catch (error) {
    console.error('❌ Leaderboard update failed:', error)
    throw error
  }
}

async function testSendNotifications() {
  console.log('🧪 Testing send-notifications function...')
  
  try {
    // Sign in as test user
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: TEST_USER_EMAIL,
      password: TEST_USER_PASSWORD
    })

    if (authError) {
      throw authError
    }

    // Call the function
    const { data, error } = await supabase.functions.invoke('send-notifications', {
      body: {
        userIds: [authData.user.id, 'test-user-2-id'],
        type: 'match_invite',
        title: 'Test Notification',
        message: 'This is a test notification from the Edge Function',
        data: {
          test: true,
          match_id: 'test-match-id'
        }
      }
    })

    if (error) {
      throw error
    }

    console.log('✅ Send notifications successful:', data)
    return data
  } catch (error) {
    console.error('❌ Send notifications failed:', error)
    throw error
  }
}

async function testDatabaseQueries() {
  console.log('🧪 Testing database queries...')
  
  try {
    // Test users query
    const { data: users, error: usersError } = await supabase
      .from('users')
      .select('*')
      .limit(5)

    if (usersError) {
      throw usersError
    }

    console.log('✅ Users query successful, found', users.length, 'users')

    // Test clubs query
    const { data: clubs, error: clubsError } = await supabase
      .from('clubs')
      .select('*')
      .limit(5)

    if (clubsError) {
      throw clubsError
    }

    console.log('✅ Clubs query successful, found', clubs.length, 'clubs')

    // Test tournaments query
    const { data: tournaments, error: tournamentsError } = await supabase
      .from('tournaments')
      .select('*')
      .limit(5)

    if (tournamentsError) {
      throw tournamentsError
    }

    console.log('✅ Tournaments query successful, found', tournaments.length, 'tournaments')

    // Test leaderboards query
    const { data: leaderboards, error: leaderboardsError } = await supabase
      .from('leaderboards')
      .select('*')
      .limit(5)

    if (leaderboardsError) {
      throw leaderboardsError
    }

    console.log('✅ Leaderboards query successful, found', leaderboards.length, 'leaderboards')

    return { users, clubs, tournaments, leaderboards }
  } catch (error) {
    console.error('❌ Database queries failed:', error)
    throw error
  }
}

async function testRealtimeSubscription() {
  console.log('🧪 Testing real-time subscriptions...')
  
  try {
    // Subscribe to matches table changes
    const matchesChannel = supabase
      .channel('matches-changes')
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'matches'
      }, (payload) => {
        console.log('📡 Real-time matches update:', payload)
      })
      .subscribe()

    // Subscribe to notifications table changes
    const notificationsChannel = supabase
      .channel('notifications-changes')
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'notifications'
      }, (payload) => {
        console.log('📡 Real-time notifications update:', payload)
      })
      .subscribe()

    console.log('✅ Real-time subscriptions established')
    
    // Clean up after 10 seconds
    setTimeout(() => {
      supabase.removeChannel(matchesChannel)
      supabase.removeChannel(notificationsChannel)
      console.log('🧹 Real-time subscriptions cleaned up')
    }, 10000)

    return { matchesChannel, notificationsChannel }
  } catch (error) {
    console.error('❌ Real-time subscriptions failed:', error)
    throw error
  }
}

// Main test runner
async function runAllTests() {
  console.log('🚀 Starting Supabase integration tests...\n')

  try {
    // Test database queries first
    await testDatabaseQueries()
    console.log()

    // Test real-time subscriptions
    await testRealtimeSubscription()
    console.log()

    // Test Edge Functions
    await testUpdateLeaderboards()
    console.log()

    // Test functions that require authentication
    // Uncomment these when you have test users set up
    /*
    await testCreateMatchFromChallenge()
    console.log()

    await testRegisterTournament()
    console.log()

    await testUpdateMatchResult()
    console.log()

    await testSendNotifications()
    console.log()
    */

    console.log('🎉 All tests completed successfully!')
  } catch (error) {
    console.error('💥 Test suite failed:', error)
    process.exit(1)
  }
}

// Export for use in other files
export {
  testCreateMatchFromChallenge,
  testRegisterTournament,
  testUpdateMatchResult,
  testUpdateLeaderboards,
  testSendNotifications,
  testDatabaseQueries,
  testRealtimeSubscription,
  runAllTests
}

// Run tests if this file is executed directly
if (import.meta.main) {
  runAllTests()
}