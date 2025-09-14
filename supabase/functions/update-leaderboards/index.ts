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

    console.log('Starting leaderboard update...')

    // Update ELO Rating Leaderboard
    await updateEloLeaderboard(supabaseClient)
    
    // Update Win Rate Leaderboard
    await updateWinRateLeaderboard(supabaseClient)
    
    // Update Total Wins Leaderboard
    await updateTotalWinsLeaderboard(supabaseClient)

    console.log('Leaderboard update completed successfully')

    return new Response(
      JSON.stringify({ 
        success: true,
        message: 'Leaderboards updated successfully',
        timestamp: new Date().toISOString()
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error updating leaderboards:', error)
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

async function updateEloLeaderboard(supabaseClient: any) {
  // Get top players by ELO rating (minimum 5 matches)
  const { data: players, error } = await supabaseClient
    .from('users')
    .select('id, display_name, username, elo_rating, total_matches')
    .gte('total_matches', 5)
    .order('elo_rating', { ascending: false })
    .limit(100)

  if (error) {
    throw new Error(`Failed to fetch ELO players: ${error.message}`)
  }

  const rankings = players.map((player: any, index: number) => ({
    rank: index + 1,
    user_id: player.id,
    username: player.display_name || player.username || 'Unknown',
    value: player.elo_rating,
    change_from_last: 0 // TODO: Calculate from previous ranking
  }))

  const leaderboardData = {
    name: 'ELO Rating Leaderboard',
    type: 'Global',
    criteria: 'elo_rating',
    time_period: 'All time',
    min_matches_required: 5,
    rankings: rankings,
    total_players: rankings.length,
    last_updated: new Date().toISOString(),
    is_active: true
  }

  // Upsert leaderboard
  const { error: upsertError } = await supabaseClient
    .from('leaderboards')
    .upsert(leaderboardData, { 
      onConflict: 'criteria,type,time_period',
      ignoreDuplicates: false 
    })

  if (upsertError) {
    throw new Error(`Failed to update ELO leaderboard: ${upsertError.message}`)
  }

  console.log(`Updated ELO leaderboard with ${rankings.length} players`)
}

async function updateWinRateLeaderboard(supabaseClient: any) {
  // Get top players by win rate (minimum 10 matches)
  const { data: players, error } = await supabaseClient
    .from('users')
    .select('id, display_name, username, win_rate, total_matches')
    .gte('total_matches', 10)
    .order('win_rate', { ascending: false })
    .limit(100)

  if (error) {
    throw new Error(`Failed to fetch win rate players: ${error.message}`)
  }

  const rankings = players.map((player: any, index: number) => ({
    rank: index + 1,
    user_id: player.id,
    username: player.display_name || player.username || 'Unknown',
    value: player.win_rate,
    change_from_last: 0
  }))

  const leaderboardData = {
    name: 'Win Rate Leaderboard',
    type: 'Global',
    criteria: 'win_rate',
    time_period: 'All time',
    min_matches_required: 10,
    rankings: rankings,
    total_players: rankings.length,
    last_updated: new Date().toISOString(),
    is_active: true
  }

  const { error: upsertError } = await supabaseClient
    .from('leaderboards')
    .upsert(leaderboardData, { 
      onConflict: 'criteria,type,time_period',
      ignoreDuplicates: false 
    })

  if (upsertError) {
    throw new Error(`Failed to update win rate leaderboard: ${upsertError.message}`)
  }

  console.log(`Updated win rate leaderboard with ${rankings.length} players`)
}

async function updateTotalWinsLeaderboard(supabaseClient: any) {
  // Get top players by total wins (minimum 1 match)
  const { data: players, error } = await supabaseClient
    .from('users')
    .select('id, display_name, username, wins, total_matches')
    .gte('total_matches', 1)
    .order('wins', { ascending: false })
    .limit(100)

  if (error) {
    throw new Error(`Failed to fetch total wins players: ${error.message}`)
  }

  const rankings = players.map((player: any, index: number) => ({
    rank: index + 1,
    user_id: player.id,
    username: player.display_name || player.username || 'Unknown',
    value: player.wins,
    change_from_last: 0
  }))

  const leaderboardData = {
    name: 'Total Wins Leaderboard',
    type: 'Global',
    criteria: 'wins',
    time_period: 'All time',
    min_matches_required: 1,
    rankings: rankings,
    total_players: rankings.length,
    last_updated: new Date().toISOString(),
    is_active: true
  }

  const { error: upsertError } = await supabaseClient
    .from('leaderboards')
    .upsert(leaderboardData, { 
      onConflict: 'criteria,type,time_period',
      ignoreDuplicates: false 
    })

  if (upsertError) {
    throw new Error(`Failed to update total wins leaderboard: ${upsertError.message}`)
  }

  console.log(`Updated total wins leaderboard with ${rankings.length} players`)
}