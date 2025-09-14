#!/bin/bash

# Supabase Deployment Script for Sabo Arena
# Make sure you have Supabase CLI installed: npm install -g supabase

echo "🚀 Starting Supabase deployment for Sabo Arena..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo -e "${RED}❌ Supabase CLI is not installed.${NC}"
    echo "Please install it with: npm install -g supabase"
    exit 1
fi

# Check if logged in
if ! supabase projects list &> /dev/null; then
    echo -e "${YELLOW}⚠️  You need to login to Supabase first.${NC}"
    echo "Run: supabase login"
    exit 1
fi

echo -e "${GREEN}✅ Supabase CLI is ready${NC}"

# Link to project
echo -e "${YELLOW}🔗 Linking to Supabase project...${NC}"
supabase link --project-ref skzirkhzwhyqmnfyytcl

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to link to Supabase project${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Successfully linked to project${NC}"

# Push database changes
echo -e "${YELLOW}🗄️  Deploying database schema...${NC}"
supabase db push

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to deploy database schema${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Database schema deployed successfully${NC}"

# Deploy Edge Functions
echo -e "${YELLOW}⚡ Deploying Edge Functions...${NC}"

# Deploy all functions
supabase functions deploy create-match-from-challenge
supabase functions deploy register-tournament  
supabase functions deploy update-match-result
supabase functions deploy update-leaderboards
supabase functions deploy send-notifications

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to deploy some Edge Functions${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All Edge Functions deployed successfully${NC}"

# Insert sample data (optional)
echo -e "${YELLOW}📊 Do you want to insert sample data? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}📊 Inserting sample data...${NC}"
    supabase db reset --db-url "postgresql://postgres:your-password@db.skzirkhzwhyqmnfyytcl.supabase.co:5432/postgres"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Sample data inserted successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Sample data insertion failed, but deployment continues${NC}"
    fi
fi

# Setup cron jobs (optional)
echo -e "${YELLOW}⏰ Do you want to setup cron jobs? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}⏰ Setting up cron jobs...${NC}"
    supabase db shell < supabase/cron_jobs.sql
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Cron jobs setup successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Cron jobs setup failed, you may need to run them manually${NC}"
    fi
fi

echo -e "${GREEN}🎉 Supabase deployment completed successfully!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Configure OAuth providers in Supabase Dashboard"
echo "2. Set up storage buckets and policies"
echo "3. Test the Edge Functions"
echo "4. Update your Flutter app with the new configuration"
echo ""
echo -e "${YELLOW}🔗 Useful links:${NC}"
echo "Dashboard: https://supabase.com/dashboard/project/skzirkhzwhyqmnfyytcl"
echo "Functions: https://supabase.com/dashboard/project/skzirkhzwhyqmnfyytcl/functions"
echo "Database: https://supabase.com/dashboard/project/skzirkhzwhyqmnfyytcl/editor"
echo ""
echo -e "${GREEN}Happy coding! 🎱⚡${NC}"