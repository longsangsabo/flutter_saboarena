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
    const { challengeId } = await req.json()

    if (!challengeId) {
      return new Response(
        JSON.stringify({ error: 'Challenge ID is required' }),
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

    // Get challenge details
    const { data: challenge, error: challengeError } = await supabaseClient
      .from('challenges')
      .select('*')
      .eq('id', challengeId)
      .single()

    if (challengeError || !challenge) {
      return new Response(
        JSON.stringify({ error: 'Challenge not found' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Verify challenge is accepted
    if (challenge.status !== 'Accepted') {
      return new Response(
        JSON.stringify({ error: 'Challenge not accepted' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Create match document
    const matchData = {
      club_id: challenge.club_id,
      player1_id: challenge.challenger_id,
      player2_id: challenge.challenged_id,
      game_type: challenge.game_type,
      match_format: challenge.match_format,
      scheduled_time: challenge.accepted_time,
      status: 'Scheduled',
      match_type: 'Challenge',
      is_ranked: true,
      stakes: challenge.stakes || 0,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }

    // Insert match
    const { data: match, error: matchError } = await supabaseClient
      .from('matches')
      .insert(matchData)
      .select()
      .single()

    if (matchError) {
      throw matchError
    }

    // Update challenge with resulting match ID
    const { error: updateError } = await supabaseClient
      .from('challenges')
      .update({
        resulting_match_id: match.id,
        status: 'Completed',
        updated_at: new Date().toISOString()
      })
      .eq('id', challengeId)

    if (updateError) {
      throw updateError
    }

    return new Response(
      JSON.stringify({ matchId: match.id }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error creating match from challenge:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})