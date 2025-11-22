-- Add SSO integration fields to user table
ALTER TABLE "user" 
ADD COLUMN IF NOT EXISTS sso_subject VARCHAR(255) UNIQUE,
ADD COLUMN IF NOT EXISTS sso_provider VARCHAR(50),
ADD COLUMN IF NOT EXISTS email VARCHAR(255) UNIQUE,
ADD COLUMN IF NOT EXISTS picture_url VARCHAR(2183),
ADD COLUMN IF NOT EXISTS sso_data JSONB;

-- Create index on sso_subject for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_sso_subject ON "user"(sso_subject);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_email ON "user"(email);

-- Create index on sso_provider for filtering
CREATE INDEX IF NOT EXISTS idx_user_sso_provider ON "user"(sso_provider);