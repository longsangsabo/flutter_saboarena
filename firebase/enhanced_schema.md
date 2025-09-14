# 🎱 Sabo Arena Enhanced Firebase Schema

## 📊 Enhanced Collections Structure

### 1. 👤 **users** (Enhanced)
```javascript
{
  // Basic Info
  uid: string,
  email: string,
  full_name: string,
  display_name: string,
  username: string, // NEW: Unique username
  photo_url: string,
  phone_number: string,
  location: string,
  birth_date: timestamp, // NEW: For age verification
  gender: string, // NEW: Male/Female/Other
  
  // Game Statistics
  elo_rating: number,
  overall_ranking: number,
  total_matches: number,
  wins: number, // NEW: Total wins
  losses: number, // NEW: Total losses
  draws: number, // NEW: Total draws
  win_rate: number,
  average_match_duration: number, // NEW: in minutes
  favorite_game_type: string, // NEW: 8-ball, 9-ball, etc.
  skill_level: string, // NEW: Beginner, Intermediate, Advanced, Pro
  
  // Activity & Status
  is_online: boolean,
  last_active: timestamp,
  account_status: string,
  is_verified: boolean, // NEW: Account verification
  is_banned: boolean, // NEW: Ban status
  ban_reason: string, // NEW: Reason for ban if any
  
  // Preferences
  preferred_language: string, // NEW: Language preference
  notification_settings: map, // NEW: Notification preferences
  privacy_settings: map, // NEW: Privacy settings
  
  // Timestamps
  created_time: timestamp,
  updated_time: timestamp
}
```

### 2. 🏢 **clubs** (Enhanced)
```javascript
{
  club_id: string,
  name: string,
  description: string,
  address: string,
  phone: string,
  email: string, // NEW: Club email
  website: string, // NEW: Club website
  
  // Media
  logo_url: string,
  cover_image_url: string,
  gallery_images: array, // NEW: Club photo gallery
  
  // Location & Facilities
  coordinates: geopoint, // NEW: GPS coordinates
  opening_hours: map, // NEW: Daily opening hours
  facilities: array, // NEW: Number of tables, amenities
  table_count: number, // NEW: Total billiard tables
  table_types: array, // NEW: 8-ball, 9-ball, snooker tables
  
  // Club Management
  owner_id: string, // NEW: Club owner reference
  staff_ids: array, // NEW: Staff member IDs
  member_count: number,
  max_members: number, // NEW: Membership limit
  membership_fee: number, // NEW: Monthly/yearly fee
  is_verified: boolean, // NEW: Official verification
  
  // Business Info
  business_license: string, // NEW: License number
  tax_id: string, // NEW: Tax identification
  rating: number, // NEW: Average club rating
  total_reviews: number, // NEW: Total review count
  
  // Settings
  is_public: boolean, // NEW: Public or private club
  require_approval: boolean, // NEW: Membership approval required
  allow_tournaments: boolean, // NEW: Tournament hosting allowed
  tournament_fee_percentage: number, // NEW: Club's tournament fee cut
  
  // Timestamps
  created_time: timestamp,
  updated_time: timestamp,
  status: string // NEW: Active, Inactive, Suspended
}
```

### 3. 🏆 **tournaments** (Enhanced)
```javascript
{
  tournament_id: string,
  club_id: string,
  name: string,
  description: string,
  tournament_type: string, // NEW: Single/Double Elimination, Round Robin
  game_type: string, // NEW: 8-ball, 9-ball, snooker
  
  // Tournament Details
  max_participants: number,
  current_participants: number, // NEW: Current participant count
  entry_fee: number,
  prize_pool: number,
  prize_distribution: map, // NEW: 1st, 2nd, 3rd place prizes
  
  // Scheduling
  start_time: timestamp,
  end_time: timestamp,
  registration_deadline: timestamp, // NEW: Registration cutoff
  estimated_duration: number, // NEW: Expected tournament length
  
  // Rules & Format
  match_format: string, // NEW: Best of 3, Best of 5, etc.
  time_limit_per_match: number, // NEW: Match time limit
  break_rule: string, // NEW: Break rules
  foul_rules: array, // NEW: Specific foul rules
  
  // Tournament Status
  status: string, // Registration, In Progress, Completed, Cancelled
  current_round: number, // NEW: Current tournament round
  total_rounds: number, // NEW: Total expected rounds
  
  // Management
  organizer_id: string, // NEW: Tournament organizer
  referees: array, // NEW: Assigned referees
  sponsors: array, // NEW: Tournament sponsors
  
  // Results
  winner_id: string,
  runner_up_id: string, // NEW: Second place
  third_place_id: string, // NEW: Third place
  
  // Media & Promotion
  banner_image: string, // NEW: Tournament banner
  live_stream_url: string, // NEW: Live streaming link
  social_media_hashtag: string, // NEW: Tournament hashtag
  
  // Timestamps
  created_time: timestamp,
  updated_time: timestamp
}
```

### 4. 🎯 **matches** (Enhanced)
```javascript
{
  match_id: string,
  tournament_id: string, // Optional for tournament matches
  club_id: string,
  
  // Players
  player1_id: string,
  player2_id: string,
  player1_name: string, // NEW: Player names for quick access
  player2_name: string,
  
  // Match Details
  game_type: string, // NEW: 8-ball, 9-ball, snooker
  match_format: string, // NEW: Best of 3, Best of 5
  table_number: number, // NEW: Assigned table
  
  // Scoring
  player1_score: number,
  player2_score: number,
  player1_games_won: number, // NEW: Games won in the match
  player2_games_won: number,
  winner_id: string,
  
  // Game-by-Game Results
  games: array, // NEW: Individual game results
  /*
  games: [
    {
      game_number: 1,
      winner_id: string,
      break_player_id: string,
      shots_taken: {player1: number, player2: number},
      fouls: {player1: number, player2: number},
      duration: number
    }
  ]
  */
  
  // Match Statistics
  total_shots: map, // NEW: Total shots per player
  successful_shots: map, // NEW: Successful shots per player
  fouls_committed: map, // NEW: Fouls per player
  accuracy_percentage: map, // NEW: Shot accuracy per player
  longest_run: map, // NEW: Longest run per player
  
  // Timing
  scheduled_time: timestamp,
  actual_start_time: timestamp, // NEW: When match actually started
  end_time: timestamp,
  match_duration: number, // NEW: Total match time in minutes
  
  // Officials & Validation
  referee_id: string, // NEW: Assigned referee
  is_verified: boolean, // NEW: Result verification
  verification_method: string, // NEW: Manual, Digital, etc.
  
  // ELO Changes
  elo_changes: map, // NEW: ELO rating changes for both players
  /*
  elo_changes: {
    player1: {before: number, after: number, change: number},
    player2: {before: number, after: number, change: number}
  }
  */
  
  // Match Status & Type
  status: string, // Scheduled, In Progress, Completed, Cancelled
  match_type: string, // Casual, Tournament, Challenge, League
  is_ranked: boolean, // NEW: Does this match affect rankings?
  
  // Additional Info
  notes: string, // NEW: Match notes
  spectator_count: number, // NEW: Number of spectators
  weather_conditions: string, // NEW: For outdoor venues
  
  // Timestamps
  created_time: timestamp,
  updated_time: timestamp
}
```

### 5. 🎮 **game_types** (NEW Collection)
```javascript
{
  game_type_id: string,
  name: string, // 8-ball, 9-ball, 10-ball, snooker, etc.
  description: string,
  rules: map,
  default_match_format: string,
  ball_count: number,
  table_type: string,
  difficulty_level: string,
  popularity_score: number,
  created_time: timestamp
}
```

### 6. 📊 **player_statistics** (NEW Collection)
```javascript
{
  user_id: string,
  club_id: string, // Optional - club-specific stats
  game_type: string, // 8-ball, 9-ball, etc.
  
  // Detailed Statistics
  total_matches: number,
  wins: number,
  losses: number,
  draws: number,
  win_percentage: number,
  
  // Shot Statistics
  total_shots: number,
  successful_shots: number,
  accuracy_percentage: number,
  average_shots_per_match: number,
  
  // Game-Specific Stats
  breaks_made: number,
  eight_ball_on_break: number, // For 8-ball
  run_outs: number, // Cleared table in one turn
  highest_run: number,
  average_match_duration: number,
  
  // Foul Statistics
  total_fouls: number,
  foul_rate: number,
  scratch_count: number,
  
  // Time-based Performance
  performance_by_time: map, // Morning, afternoon, evening performance
  performance_by_day: map, // Day of week performance
  
  // Streaks
  current_win_streak: number,
  longest_win_streak: number,
  current_loss_streak: number,
  
  // Updated timestamp
  last_updated: timestamp
}
```

### 7. 🏅 **leaderboards** (NEW Collection)
```javascript
{
  leaderboard_id: string,
  name: string,
  type: string, // Global, Club, Monthly, Weekly
  club_id: string, // Optional for club leaderboards
  game_type: string, // Optional for game-specific boards
  
  // Leaderboard Settings
  criteria: string, // ELO, Win Rate, Matches Won, etc.
  time_period: string, // All time, Monthly, Weekly
  min_matches_required: number,
  
  // Current Rankings
  rankings: array,
  /*
  rankings: [
    {
      rank: number,
      user_id: string,
      username: string,
      value: number, // The ranking value
      change_from_last: number // Position change
    }
  ]
  */
  
  // Metadata
  total_players: number,
  last_updated: timestamp,
  is_active: boolean
}
```

### 8. 💳 **transactions** (Enhanced)
```javascript
{
  transaction_id: string,
  user_id: string,
  club_id: string, // Optional
  
  // Transaction Details
  type: string, // Tournament Entry, Membership Fee, Prize Money, etc.
  amount: number,
  currency: string,
  status: string, // Pending, Completed, Failed, Refunded
  
  // Related Entities
  tournament_id: string, // Optional
  match_id: string, // Optional
  
  // Payment Info
  payment_method: string, // Credit Card, Cash, Bank Transfer, etc.
  payment_provider: string, // Stripe, PayPal, etc.
  payment_reference: string,
  
  // Timestamps
  created_time: timestamp,
  processed_time: timestamp,
  
  // Additional Info
  description: string,
  metadata: map // Additional transaction data
}
```

### 9. 🔔 **notifications** (Enhanced)
```javascript
{
  notification_id: string,
  user_id: string,
  
  // Notification Content
  title: string,
  message: string,
  type: string, // Match Invite, Tournament Update, Achievement, etc.
  priority: string, // Low, Medium, High, Urgent
  
  // Related Entities
  related_match_id: string, // Optional
  related_tournament_id: string, // Optional
  related_user_id: string, // Optional - who triggered the notification
  
  // Delivery
  is_read: boolean,
  is_sent: boolean,
  delivery_methods: array, // Push, Email, SMS
  
  // Actions
  action_url: string, // Deep link for action
  action_type: string, // View Match, Join Tournament, etc.
  
  // Timestamps
  created_time: timestamp,
  read_time: timestamp,
  expires_at: timestamp // Optional expiration
}
```

### 10. 📱 **push_tokens** (NEW Collection)
```javascript
{
  user_id: string,
  device_id: string,
  push_token: string,
  platform: string, // iOS, Android, Web
  is_active: boolean,
  last_used: timestamp,
  created_time: timestamp
}
```

### 11. 🎯 **challenges** (NEW Collection)
```javascript
{
  challenge_id: string,
  challenger_id: string,
  challenged_id: string,
  club_id: string,
  
  // Challenge Details
  game_type: string,
  match_format: string,
  stakes: number, // Optional betting amount
  message: string, // Challenge message
  
  // Scheduling
  proposed_time: timestamp,
  accepted_time: timestamp,
  table_preference: string,
  
  // Status
  status: string, // Pending, Accepted, Declined, Expired, Completed
  expiry_time: timestamp,
  
  // Result
  resulting_match_id: string, // Reference to created match
  
  // Timestamps
  created_time: timestamp,
  updated_time: timestamp
}
```