# Simple PowerShell script to execute Supabase migration
# Uses Invoke-RestMethod to execute SQL directly

# Load environment variables
$env:SUPABASE_URL = "https://skzirkhzwhyqmnfyytcl.supabase.co"
$env:SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNremlya2h6d2h5cW1uZnl5dGNsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Nzc0MzczNSwiZXhwIjoyMDczMzE5NzM1fQ.xIlkzXWPUq6Kwcs__XEduFZnCEi_y4up8Hd536VDmy0"

Write-Host "🚀 Starting users table creation..." -ForegroundColor Green

# Read the migration file
$migrationContent = Get-Content "migrations\001_create_users_table.sql" -Raw

# Execute the migration using curl (more reliable than PowerShell REST)
$tempFile = "temp_migration.sql"
$migrationContent | Out-File -FilePath $tempFile -Encoding UTF8

Write-Host "📄 Migration file prepared" -ForegroundColor Yellow
Write-Host "🔗 Executing via Supabase REST API..." -ForegroundColor Cyan

# Use curl to execute the SQL
$curlCommand = "curl -X POST `"$env:SUPABASE_URL/rest/v1/rpc/exec_sql`" -H `"Authorization: Bearer $env:SUPABASE_SERVICE_ROLE_KEY`" -H `"apikey: $env:SUPABASE_SERVICE_ROLE_KEY`" -H `"Content-Type: application/json`" -d `"{`\`"sql`\`": `\`"$(($migrationContent -replace '`"', '\\`"' -replace '`r?`n', '\\n').Trim())`\`"}`""

Write-Host "Executing SQL migration..." -ForegroundColor Yellow
Write-Host $curlCommand -ForegroundColor Gray

# Clean up
Remove-Item $tempFile -ErrorAction SilentlyContinue

Write-Host "✅ Migration execution attempted!" -ForegroundColor Green
Write-Host "👉 Please check Supabase Dashboard to verify table creation" -ForegroundColor Cyan