import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Get the payload from the request
    const { matchId, winnerId, score, gameDuration } = await req.json()

    if (!matchId || !winnerId) {
      return new Response(
        JSON.stringify({ error: 'Match ID and winner ID are required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get current user
    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser()

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { 
          status: 401, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get match details
    const { data: match, error: matchError } = await supabaseClient
      .from('matches')
      .select('*')
      .eq('id', matchId)
      .single()

    if (matchError || !match) {
      return new Response(
        JSON.stringify({ error: 'Match not found' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Verify user is involved in the match
    if (match.player1_id !== user.id && match.player2_id !== user.id) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized to update this match' }),
        { 
          status: 403, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get current ELO ratings
    const { data: players, error: playersError } = await supabaseClient
      .from('users')
      .select('id, elo_rating, total_matches, wins, losses')
      .in('id', [match.player1_id, match.player2_id])

    if (playersError || !players || players.length !== 2) {
      return new Response(
        JSON.stringify({ error: 'Failed to get player data' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const player1 = players.find(p => p.id === match.player1_id)!
    const player2 = players.find(p => p.id === match.player2_id)!

    // Calculate ELO changes
    const kFactor = 32 // K-factor for rating calculation
    const player1Elo = player1.elo_rating || 1200
    const player2Elo = player2.elo_rating || 1200
    
    const player1Expected = 1 / (1 + Math.pow(10, (player2Elo - player1Elo) / 400))
    const player2Expected = 1 - player1Expected
    
    const player1Score = winnerId === match.player1_id ? 1 : 0
    const player2Score = 1 - player1Score
    
    const player1Change = Math.round(kFactor * (player1Score - player1Expected))
    const player2Change = Math.round(kFactor * (player2Score - player2Expected))
    
    const newPlayer1Elo = Math.max(100, player1Elo + player1Change)
    const newPlayer2Elo = Math.max(100, player2Elo + player2Change)

    // Update match with result
    const { error: matchUpdateError } = await supabaseClient
      .from('matches')
      .update({
        winner_id: winnerId,
        loser_id: winnerId === match.player1_id ? match.player2_id : match.player1_id,
        score: score,
        game_duration: gameDuration,
        status: 'Completed',
        completed_time: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        elo_changes: {
          [match.player1_id]: {
            before: player1Elo,
            after: newPlayer1Elo,
            change: player1Change
          },
          [match.player2_id]: {
            before: player2Elo,
            after: newPlayer2Elo,
            change: player2Change
          }
        }
      })
      .eq('id', matchId)

    if (matchUpdateError) {
      throw matchUpdateError
    }

    // Update player statistics
    const player1Updates = {
      elo_rating: newPlayer1Elo,
      total_matches: (player1.total_matches || 0) + 1,
      wins: (player1.wins || 0) + (winnerId === match.player1_id ? 1 : 0),
      losses: (player1.losses || 0) + (winnerId !== match.player1_id ? 1 : 0),
      updated_at: new Date().toISOString()
    }

    const player2Updates = {
      elo_rating: newPlayer2Elo,
      total_matches: (player2.total_matches || 0) + 1,
      wins: (player2.wins || 0) + (winnerId === match.player2_id ? 1 : 0),
      losses: (player2.losses || 0) + (winnerId !== match.player2_id ? 1 : 0),
      updated_at: new Date().toISOString()
    }

    // Calculate win rates
    player1Updates.win_rate = player1Updates.total_matches > 0 ? 
      player1Updates.wins / player1Updates.total_matches : 0
    player2Updates.win_rate = player2Updates.total_matches > 0 ? 
      player2Updates.wins / player2Updates.total_matches : 0

    // Update both players
    await Promise.all([
      supabaseClient
        .from('users')
        .update(player1Updates)
        .eq('id', match.player1_id),
      supabaseClient
        .from('users')
        .update(player2Updates)
        .eq('id', match.player2_id)
    ])

    // Create notifications for both players
    const winnerNotification = {
      user_id: winnerId,
      type: 'match_result',
      title: 'Match Victory!',
      message: `You won the match! ELO: ${winnerId === match.player1_id ? player1Elo : player2Elo} → ${winnerId === match.player1_id ? newPlayer1Elo : newPlayer2Elo} (${winnerId === match.player1_id ? player1Change > 0 ? '+' : '' : player2Change > 0 ? '+' : ''}${winnerId === match.player1_id ? player1Change : player2Change})`,
      data: {
        match_id: matchId,
        elo_change: winnerId === match.player1_id ? player1Change : player2Change
      },
      is_read: false,
      created_at: new Date().toISOString()
    }

    const loserId = winnerId === match.player1_id ? match.player2_id : match.player1_id
    const loserNotification = {
      user_id: loserId,
      type: 'match_result',
      title: 'Match Completed',
      message: `Match finished. ELO: ${loserId === match.player1_id ? player1Elo : player2Elo} → ${loserId === match.player1_id ? newPlayer1Elo : newPlayer2Elo} (${loserId === match.player1_id ? player1Change > 0 ? '+' : '' : player2Change > 0 ? '+' : ''}${loserId === match.player1_id ? player1Change : player2Change})`,
      data: {
        match_id: matchId,
        elo_change: loserId === match.player1_id ? player1Change : player2Change
      },
      is_read: false,
      created_at: new Date().toISOString()
    }

    await supabaseClient
      .from('notifications')
      .insert([winnerNotification, loserNotification])

    return new Response(
      JSON.stringify({ 
        success: true,
        eloChanges: {
          [match.player1_id]: {
            before: player1Elo,
            after: newPlayer1Elo,
            change: player1Change
          },
          [match.player2_id]: {
            before: player2Elo,
            after: newPlayer2Elo,
            change: player2Change
          }
        }
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error updating match result:', error)
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})