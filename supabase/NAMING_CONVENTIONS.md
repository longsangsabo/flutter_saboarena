# 📋 Sabo Arena Database Naming Conventions & Schema Rules

## 🎯 **Mục tiêu**
Thiết lập quy tắc đặt tên nhất quán cho PostgreSQL database của Supabase để đảm bảo:
- Tính nhất quán trong toàn bộ dự án
- Dễ dàng maintenance và collaboration
- Tuân thủ best practices của PostgreSQL và Supabase

---

## 📚 **1. NAMING CONVENTIONS**

### 🏷️ **Table Names (Tên bảng)**
- **Format**: `snake_case` (chữ thường, dấu gạch dưới)
- **Số ít**: Sử dụng danh từ số ít
- **Tiếng Anh**: Tất cả tên bảng bằng tiếng Anh

**Ví dụ:**
```sql
✅ ĐÚNG: user, club, tournament, match, notification
❌ SAI: Users, Clubs, tournaments, Matches, thông_báo
```

### 🔑 **Column Names (Tên cột)**
- **Format**: `snake_case`
- **Descriptive**: Tên mô tả rõ ràng, không viết tắt
- **Consistent**: Cùng một ý nghĩa thì cùng tên trong mọi bảng

**Standard columns:**
```sql
- id: Primary key (UUID)
- created_at: TIMESTAMPTZ DEFAULT NOW()
- updated_at: TIMESTAMPTZ DEFAULT NOW()
- deleted_at: TIMESTAMPTZ (cho soft delete)
```

**Foreign key pattern:**
```sql
- user_id: Reference đến bảng user
- club_id: Reference đến bảng club
- tournament_id: Reference đến bảng tournament
```

### 🔗 **Relationship Tables (Bảng quan hệ nhiều-nhiều)**
- **Format**: `table1_table2` (theo thứ tự alphabet)
- **Hoặc**: Tên nghiệp vụ rõ ràng

**Ví dụ:**
```sql
✅ ĐÚNG: club_member, tournament_participant
✅ ĐÚNG: user_follow (thay vì user_user)
❌ SAI: member_club, participant_tournament
```

### 📊 **Indexes (Chỉ mục)**
- **Format**: `idx_tablename_columnname`
- **Unique**: `uniq_tablename_columnname`
- **Composite**: `idx_tablename_col1_col2`

**Ví dụ:**
```sql
CREATE INDEX idx_user_email ON user(email);
CREATE UNIQUE INDEX uniq_user_username ON user(username);
CREATE INDEX idx_match_player1_player2 ON match(player1_id, player2_id);
```

### 🛡️ **RLS Policies (Row Level Security)**
- **Format**: `policy_action_tablename_condition`
- **Readable**: Mô tả rõ ràng action và condition

**Ví dụ:**
```sql
CREATE POLICY policy_select_user_own ON user FOR SELECT USING (auth.uid() = id);
CREATE POLICY policy_insert_match_participant ON match FOR INSERT WITH CHECK (auth.uid() IN (player1_id, player2_id));
```

---

## 🗄️ **2. DATABASE SCHEMA STRUCTURE**

### 🏗️ **Core Tables (Bảng cơ bản)**

```sql
1. user              - Thông tin người dùng
2. club              - Câu lạc bộ billiards
3. tournament        - Giải đấu
4. match             - Trận đấu
5. notification      - Thông báo
```

### 🔗 **Relationship Tables (Bảng quan hệ)**

```sql
6. club_member           - Thành viên câu lạc bộ
7. tournament_participant - Người tham gia giải đấu
8. challenge            - Thách đấu giữa players
9. chat_message         - Tin nhắn chat
10. leaderboard         - Bảng xếp hạng
11. player_statistic    - Thống kê người chơi
```

### 📊 **Data Types Standards**

```sql
- ID: UUID PRIMARY KEY DEFAULT gen_random_uuid()
- Timestamps: TIMESTAMPTZ DEFAULT NOW()
- Money: DECIMAL(10,2) 
- Text: TEXT (không giới hạn length)
- Short text: VARCHAR(255)
- Boolean: BOOLEAN DEFAULT FALSE
- JSON: JSONB (cho flexibility)
- Enum: Custom ENUM types
```

---

## 🎱 **3. BILLIARDS DOMAIN SPECIFIC**

### 🎮 **Game Types (Enum)**
```sql
CREATE TYPE game_type AS ENUM (
    '8-ball',
    '9-ball', 
    '10-ball',
    'straight-pool',
    'bank-pool',
    'one-pocket'
);
```

### 🏆 **Tournament Formats (Enum)**
```sql
CREATE TYPE tournament_format AS ENUM (
    'single-elimination',
    'double-elimination', 
    'round-robin',
    'swiss-system'
);
```

### 📊 **Match Status (Enum)**
```sql
CREATE TYPE match_status AS ENUM (
    'scheduled',
    'in-progress',
    'completed',
    'cancelled',
    'postponed'
);
```

### 🎯 **Skill Levels (Enum)**
```sql
CREATE TYPE skill_level AS ENUM (
    'beginner',
    'intermediate',
    'advanced',
    'expert',
    'professional'
);
```

---

## 🔒 **4. SECURITY GUIDELINES**

### 🛡️ **RLS (Row Level Security)**
- **Enable** cho tất cả tables có user data
- **Policies** rõ ràng cho SELECT, INSERT, UPDATE, DELETE
- **Performance** optimization với proper indexes

### 🔐 **Authentication Integration**
```sql
-- Sử dụng auth.uid() để reference current user
-- Sử dụng auth.role() để check permissions
-- Sử dụng auth.jwt() để get additional claims
```

### 🚫 **Data Protection**
- Soft delete với `deleted_at` thay vì hard delete
- Audit trails cho sensitive operations
- Encrypt sensitive data nếu cần

---

## 📈 **5. PERFORMANCE OPTIMIZATION**

### 🚀 **Indexing Strategy**
```sql
-- Primary keys: Automatic
-- Foreign keys: Always index
-- Query columns: Index frequently queried columns
-- Composite: For multi-column WHERE clauses
-- Partial: For conditional queries
```

### 📊 **Query Optimization**
- Sử dụng EXPLAIN ANALYZE để check performance
- Avoid N+1 queries với proper JOINs
- Use pagination cho large datasets
- Consider materialized views cho complex aggregations

---

## 🔄 **6. MIGRATION STRATEGY**

### 📝 **Schema Versioning**
```
supabase/migrations/
├── 001_create_users_table.sql
├── 002_create_clubs_table.sql  
├── 003_create_tournaments_table.sql
├── 004_create_matches_table.sql
├── 005_create_relationships_tables.sql
├── 006_create_indexes.sql
├── 007_enable_rls_policies.sql
└── 008_insert_sample_data.sql
```

### 🔧 **Best Practices**
- Mỗi migration file chỉ làm một việc specific
- Always có rollback strategy
- Test migrations trên staging trước
- Document changes trong comments

---

## 🎯 **7. CODING STANDARDS FOR COPILOTS**

### 📋 **Checklist for Table Creation**
```sql
✅ Table name: snake_case, singular
✅ Primary key: id UUID DEFAULT gen_random_uuid()
✅ Timestamps: created_at, updated_at (with triggers)
✅ Soft delete: deleted_at TIMESTAMPTZ NULL
✅ Foreign keys: proper constraints with ON DELETE/UPDATE
✅ Indexes: on foreign keys and query columns
✅ RLS: Enable và create appropriate policies
✅ Comments: Document purpose và business rules
```

### 🔄 **Template cho mỗi table:**
```sql
-- 1. Create table with columns
-- 2. Add constraints and foreign keys  
-- 3. Create indexes
-- 4. Enable RLS
-- 5. Create RLS policies
-- 6. Add triggers (updated_at)
-- 7. Add comments
```

---

**📌 Note**: Tất cả copilots khi làm việc với database phải follow exactly các quy tắc này để đảm bảo consistency!