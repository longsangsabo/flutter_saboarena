# 🚀 Quick Start Guide - Supabase Migration

## TL;DR - Deploy ngay trong 5 phút!

### 1. Prerequisites
```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login
```

### 2. Quick Deploy (Windows PowerShell)
```powershell
# Navigate to project directory
cd C:\Users\admin\Downloads\sabo_arena\sabo_arena

# Run deployment script
.\supabase\deploy.ps1
```

### 3. Quick Deploy (Linux/Mac)
```bash
# Navigate to project directory
cd /path/to/sabo_arena

# Make script executable
chmod +x supabase/deploy.sh

# Run deployment script
./supabase/deploy.sh
```

### 4. Manual Deploy (if scripts fail)
```bash
# Link project
supabase link --project-ref skzirkhzwhyqmnfyytcl

# Deploy database
supabase db push

# Deploy functions
supabase functions deploy
```

### 5. Essential URLs
- **Dashboard**: https://supabase.com/dashboard/project/skzirkhzwhyqmnfyytcl
- **Database Editor**: https://supabase.com/dashboard/project/skzirkhzwhyqmnfyytcl/editor
- **Functions**: https://supabase.com/dashboard/project/skzirkhzwhyqmnfyytcl/functions
- **Authentication**: https://supabase.com/dashboard/project/skzirkhzwhyqmnfyytcl/auth/users

### 6. Test Your Deployment
```bash
# Test database connection
supabase db shell
```

```sql
-- Test query
SELECT * FROM users LIMIT 5;
```

### 7. Configure OAuth (In Supabase Dashboard)
1. Go to Authentication > Settings
2. Enable Google OAuth:
   - Redirect URL: `io.supabase.saboarena://login-callback`
3. Save your Google Client ID/Secret

### 8. Test Functions
```bash
# Test update leaderboards
curl -X POST https://skzirkhzwhyqmnfyytcl.supabase.co/functions/v1/update-leaderboards \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### 9. Flutter App Integration
Your Flutter app is already configured with the correct keys in:
- `lib/core/supabase_config.dart`

Just run:
```bash
flutter pub get
flutter run
```

### 🎯 What's Already Configured

✅ **Database Schema** - All tables, relations, indexes, RLS policies  
✅ **Edge Functions** - 5 functions for match management, tournaments, ELO  
✅ **Sample Data** - Test users, clubs, tournaments, matches  
✅ **Cron Jobs** - Auto leaderboard updates, cleanup tasks  
✅ **Flutter Services** - Auth, Database, Storage, Realtime  
✅ **Environment Variables** - All keys and URLs configured  

### 🔧 If Something Breaks

1. **Database issues**: Check migrations in `supabase/migrations/`
2. **Function errors**: Check logs with `supabase functions logs`
3. **Auth problems**: Verify OAuth settings in dashboard
4. **Connection issues**: Confirm project ID and keys

### 📱 Ready to Test
Your Sabo Arena app should now work with:
- ✅ User registration/login
- ✅ Club management
- ✅ Tournament creation
- ✅ Match recording with ELO updates
- ✅ Real-time leaderboards
- ✅ Push notifications

**Project ID**: `skzirkhzwhyqmnfyytcl`  
**Status**: 🟢 Ready for production!

---

*Any issues? Check the full deployment guide in `DEPLOYMENT.md` or the troubleshooting section.*