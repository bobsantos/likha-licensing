-- Fix User ID Type Compatibility Issue
-- This migration ensures proper UUID type consistency for users.id column
-- V1 creates users table correctly, but this migration handles any edge cases

-- Check and fix users table id column type if needed
DO $$
DECLARE
    users_id_type TEXT;
    table_exists BOOLEAN;
BEGIN
    -- Check if users table exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'users' AND table_schema = 'public'
    ) INTO table_exists;
    
    IF table_exists THEN
        -- Get the current data type of users.id
        SELECT data_type INTO users_id_type
        FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'id' 
        AND table_schema = 'public';
        
        RAISE NOTICE 'Current users.id data type: %', users_id_type;
        
        -- If users.id is not UUID, this indicates a serious schema inconsistency
        -- The V1 migration should have created it as UUID
        IF users_id_type != 'uuid' THEN
            RAISE EXCEPTION 'Critical schema error: users.id has type % but should be uuid. This indicates V1 migration did not execute correctly. Please check V1 migration and restart with a clean database.', users_id_type;
        ELSE
            RAISE NOTICE 'users.id has correct UUID type - no fix needed';
        END IF;
    ELSE
        RAISE EXCEPTION 'users table does not exist. V1 migration must be applied first.';
    END IF;
END $$;

