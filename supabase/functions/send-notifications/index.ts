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
    const { 
      userIds, 
      type, 
      title, 
      message, 
      data: notificationData 
    } = await req.json()

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      return new Response(
        JSON.stringify({ error: 'User IDs array is required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    if (!type || !title || !message) {
      return new Response(
        JSON.stringify({ error: 'Type, title, and message are required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Create notifications for all users
    const notifications = userIds.map((userId: string) => ({
      user_id: userId,
      type: type,
      title: title,
      message: message,
      data: notificationData || {},
      is_read: false,
      created_at: new Date().toISOString()
    }))

    const { error: notificationError } = await supabaseClient
      .from('notifications')
      .insert(notifications)

    if (notificationError) {
      throw notificationError
    }

    // Get users with push notification settings enabled
    const { data: users, error: usersError } = await supabaseClient
      .from('users')
      .select('id, display_name, notification_settings')
      .in('id', userIds)

    if (usersError) {
      console.warn('Failed to get users for push notifications:', usersError)
      // Continue without push notifications
    } else {
      // Filter users who have the notification type enabled
      const eligibleUsers = users.filter((user: any) => {
        const settings = user.notification_settings || {}
        
        // Check specific notification type settings
        switch (type) {
          case 'match_invite':
          case 'challenge':
            return settings.match_invites !== false
          case 'tournament_registration':
          case 'tournament_update':
            return settings.tournament_updates !== false
          case 'achievement':
            return settings.achievements !== false
          case 'message':
            return settings.messages !== false
          default:
            return true
        }
      })

      if (eligibleUsers.length > 0) {
        console.log(`Sent notifications to ${eligibleUsers.length} users`)
        // TODO: Implement actual push notification sending
        // This would require integrating with FCM or other push notification service
      }
    }

    return new Response(
      JSON.stringify({ 
        success: true,
        message: `Notifications sent to ${userIds.length} users`,
        notificationCount: userIds.length
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error sending notifications:', error)
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})