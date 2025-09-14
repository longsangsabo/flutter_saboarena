# Supabase Deployment Script for Sabo Arena (PowerShell)
# Make sure you have Supabase CLI installed: npm install -g supabase

Write-Host "🚀 Starting Supabase deployment for Sabo Arena..." -ForegroundColor Green

# Check if Supabase CLI is installed
try {
    supabase --version | Out-Null
    Write-Host "✅ Supabase CLI is ready" -ForegroundColor Green
} catch {
    Write-Host "❌ Supabase CLI is not installed." -ForegroundColor Red
    Write-Host "Please install it with: npm install -g supabase" -ForegroundColor Yellow
    exit 1
}

# Check if logged in
try {
    supabase projects list | Out-Null
    Write-Host "✅ Authenticated with Supabase" -ForegroundColor Green
} catch {
    Write-Host "⚠️  You need to login to Supabase first." -ForegroundColor Yellow
    Write-Host "Run: supabase login" -ForegroundColor Yellow
    exit 1
}

# Link to project
Write-Host "🔗 Linking to Supabase project..." -ForegroundColor Yellow
try {
    supabase link --project-ref skzirkhzwhyqmnfyytcl
    Write-Host "✅ Successfully linked to project" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to link to Supabase project" -ForegroundColor Red
    exit 1
}

# Push database changes
Write-Host "🗄️  Deploying database schema..." -ForegroundColor Yellow
try {
    supabase db push
    Write-Host "✅ Database schema deployed successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to deploy database schema" -ForegroundColor Red
    exit 1
}

# Deploy Edge Functions
Write-Host "⚡ Deploying Edge Functions..." -ForegroundColor Yellow
try {
    supabase functions deploy create-match-from-challenge
    supabase functions deploy register-tournament  
    supabase functions deploy update-match-result
    supabase functions deploy update-leaderboards
    supabase functions deploy send-notifications
    Write-Host "✅ All Edge Functions deployed successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to deploy some Edge Functions" -ForegroundColor Red
    exit 1
}

# Insert sample data (optional)
$response = Read-Host "📊 Do you want to insert sample data? (y/n)"
if ($response -match "^[Yy]") {
    Write-Host "📊 Inserting sample data..." -ForegroundColor Yellow
    try {
        supabase db reset --db-url "postgresql://postgres:your-password@db.skzirkhzwhyqmnfyytcl.supabase.co:5432/postgres"
        Write-Host "✅ Sample data inserted successfully" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Sample data insertion failed, but deployment continues" -ForegroundColor Yellow
    }
}

# Setup cron jobs (optional)
$response = Read-Host "⏰ Do you want to setup cron jobs? (y/n)"
if ($response -match "^[Yy]") {
    Write-Host "⏰ Setting up cron jobs..." -ForegroundColor Yellow
    try {
        Get-Content "supabase/cron_jobs.sql" | supabase db shell
        Write-Host "✅ Cron jobs setup successfully" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Cron jobs setup failed, you may need to run them manually" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🎉 Supabase deployment completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Configure OAuth providers in Supabase Dashboard"
Write-Host "2. Set up storage buckets and policies"
Write-Host "3. Test the Edge Functions"
Write-Host "4. Update your Flutter app with the new configuration"
Write-Host ""
Write-Host "🔗 Useful links:" -ForegroundColor Yellow
Write-Host "Dashboard: https://supabase.com/dashboard/project/skzirkhzwhyqmnfyytcl"
Write-Host "Functions: https://supabase.com/dashboard/project/skzirkhzwhyqmnfyytcl/functions"
Write-Host "Database: https://supabase.com/dashboard/project/skzirkhzwhyqmnfyytcl/editor"
Write-Host ""
Write-Host "Happy coding! 🎱⚡" -ForegroundColor Green