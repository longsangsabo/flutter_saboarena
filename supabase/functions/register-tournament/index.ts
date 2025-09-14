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
    const { tournamentId } = await req.json()

    if (!tournamentId) {
      return new Response(
        JSON.stringify({ error: 'Tournament ID is required' }),
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

    // Get tournament details
    const { data: tournament, error: tournamentError } = await supabaseClient
      .from('tournaments')
      .select('*')
      .eq('id', tournamentId)
      .single()

    if (tournamentError || !tournament) {
      return new Response(
        JSON.stringify({ error: 'Tournament not found' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Check if registration is still open
    if (tournament.status !== 'Registration' && tournament.status !== 'Open') {
      return new Response(
        JSON.stringify({ error: 'Registration closed' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Check if tournament is full
    if (tournament.current_participants >= tournament.max_participants) {
      return new Response(
        JSON.stringify({ error: 'Tournament is full' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Check if user is already registered
    const { data: existingRegistration } = await supabaseClient
      .from('tournament_participants')
      .select('id')
      .eq('tournament_id', tournamentId)
      .eq('user_id', user.id)
      .single()

    if (existingRegistration) {
      return new Response(
        JSON.stringify({ error: 'Already registered' }),
        { 
          status: 409, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Create participant document
    const participantData = {
      tournament_id: tournamentId,
      user_id: user.id,
      registration_time: new Date().toISOString(),
      status: 'Registered',
      seed: tournament.current_participants + 1,
      eliminated_in_round: null,
      final_position: null
    }

    const { error: participantError } = await supabaseClient
      .from('tournament_participants')
      .insert(participantData)

    if (participantError) {
      throw participantError
    }

    // Update tournament participant count
    const { error: updateError } = await supabaseClient
      .from('tournaments')
      .update({
        current_participants: tournament.current_participants + 1,
        updated_at: new Date().toISOString()
      })
      .eq('id', tournamentId)

    if (updateError) {
      throw updateError
    }

    // Create notification for successful registration
    const notificationData = {
      user_id: user.id,
      type: 'tournament_registration',
      title: 'Tournament Registration Successful',
      message: `You have successfully registered for "${tournament.name}"`,
      data: {
        tournament_id: tournamentId,
        tournament_name: tournament.name
      },
      is_read: false,
      created_at: new Date().toISOString()
    }

    await supabaseClient
      .from('notifications')
      .insert(notificationData)

    return new Response(
      JSON.stringify({ 
        success: true,
        message: 'Successfully registered for tournament',
        tournamentId: tournamentId
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error registering for tournament:', error)
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})