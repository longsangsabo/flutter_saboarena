# PowerShell script to run Supabase migration
# Run users table migration using REST API and service role key

param(
    [string]$MigrationFile = "migrations\001_create_users_table.sql"
)

# Load environment variables from .env file
function Load-DotEnv {
    param([string]$Path = ".env")
    
    if (Test-Path $Path) {
        Get-Content $Path | ForEach-Object {
            if ($_ -match "^([^#][^=]+)=(.*)$") {
                $name = $matches[1].Trim()
                $value = $matches[2].Trim()
                [Environment]::SetEnvironmentVariable($name, $value, "Process")
            }
        }
    }
}

try {
    Write-Host "🚀 Starting Supabase migration..." -ForegroundColor Green
    
    # Load environment variables
    Load-DotEnv
    
    $SUPABASE_URL = [Environment]::GetEnvironmentVariable("SUPABASE_URL", "Process")
    $SERVICE_ROLE_KEY = [Environment]::GetEnvironmentVariable("SUPABASE_SERVICE_ROLE_KEY", "Process")
    
    if (-not $SUPABASE_URL -or -not $SERVICE_ROLE_KEY) {
        throw "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in .env file"
    }
    
    Write-Host "📍 Supabase URL: $SUPABASE_URL" -ForegroundColor Cyan
    
    # Read migration SQL file
    if (-not (Test-Path $MigrationFile)) {
        throw "Migration file not found: $MigrationFile"
    }
    
    $migrationSQL = Get-Content $MigrationFile -Raw
    Write-Host "📄 Loaded migration file: $MigrationFile" -ForegroundColor Yellow
    
    # Split SQL into individual statements (rough split by semicolon + newline)
    $statements = $migrationSQL -split ";\s*\n" | Where-Object { $_.Trim() -ne "" }
    
    Write-Host "📊 Found $($statements.Count) SQL statements to execute" -ForegroundColor Yellow
    
    # Execute each statement
    $successCount = 0
    foreach ($statement in $statements) {
        $cleanStatement = $statement.Trim()
        if ($cleanStatement -eq "" -or $cleanStatement.StartsWith("--")) {
            continue
        }
        
        # Add semicolon if missing
        if (-not $cleanStatement.EndsWith(";")) {
            $cleanStatement += ";"
        }
        
        try {
            # Use SQL editor endpoint
            $body = @{
                query = $cleanStatement
            } | ConvertTo-Json -Depth 10
            
            $headers = @{
                "Authorization" = "Bearer $SERVICE_ROLE_KEY"
                "apikey" = $SERVICE_ROLE_KEY
                "Content-Type" = "application/json"
                "Prefer" = "return=minimal"
            }
            
            $response = Invoke-RestMethod -Uri "$SUPABASE_URL/rest/v1/rpc/query" -Method POST -Body $body -Headers $headers -ErrorAction Stop
            
            $successCount++
            Write-Host "✅ Statement $successCount executed successfully" -ForegroundColor Green
            
        } catch {
            # Try alternative endpoint for direct SQL execution
            try {
                $directBody = @{
                    sql = $cleanStatement
                } | ConvertTo-Json
                
                $directResponse = Invoke-RestMethod -Uri "$SUPABASE_URL/sql" -Method POST -Body $directBody -Headers $headers -ErrorAction Stop
                
                $successCount++
                Write-Host "✅ Statement $successCount executed successfully (direct SQL)" -ForegroundColor Green
                
            } catch {
                Write-Host "❌ Failed to execute statement: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "Statement: $($cleanStatement.Substring(0, [Math]::Min(100, $cleanStatement.Length)))..." -ForegroundColor Gray
            }
        }
    }
    
    Write-Host "🎉 Migration completed! Successfully executed $successCount statements." -ForegroundColor Green
    
} catch {
    Write-Host "💥 Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}