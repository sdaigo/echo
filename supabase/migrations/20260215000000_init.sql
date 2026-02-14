-- Enable pg_trgm extension for full-text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Posts table
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content TEXT NOT NULL CHECK (char_length(content) >= 1 AND char_length(content) <= 280),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Tags table
CREATE TABLE tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL CHECK (char_length(name) >= 1 AND char_length(name) <= 50),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Post-Tag junction table
CREATE TABLE post_tags (
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, tag_id)
);

-- Indexes
CREATE INDEX idx_posts_user_timeline ON posts (user_id, created_at DESC);
CREATE UNIQUE INDEX idx_tags_user_name ON tags (user_id, name);
CREATE INDEX idx_posts_content_trgm ON posts USING gin (content gin_trgm_ops);
CREATE INDEX idx_post_tags_tag_id ON post_tags (tag_id);

-- Enable RLS on all tables
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_tags ENABLE ROW LEVEL SECURITY;

-- Posts RLS policies
-- NOTE: UPDATE policy is intentionally omitted. Posts are immutable by design (delete and re-create).
CREATE POLICY "posts_select" ON posts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "posts_insert" ON posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "posts_delete" ON posts FOR DELETE USING (auth.uid() = user_id);

-- Tags RLS policies
-- NOTE: UPDATE policy is intentionally omitted. Tag names are immutable (delete and re-create).
CREATE POLICY "tags_select" ON tags FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "tags_insert" ON tags FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "tags_delete" ON tags FOR DELETE USING (auth.uid() = user_id);

-- Post-Tags RLS policies
CREATE POLICY "post_tags_select" ON post_tags FOR SELECT
  USING (EXISTS (SELECT 1 FROM posts WHERE posts.id = post_tags.post_id AND posts.user_id = auth.uid()));
CREATE POLICY "post_tags_insert" ON post_tags FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM posts WHERE posts.id = post_tags.post_id AND posts.user_id = auth.uid()));
CREATE POLICY "post_tags_delete" ON post_tags FOR DELETE
  USING (EXISTS (SELECT 1 FROM posts WHERE posts.id = post_tags.post_id AND posts.user_id = auth.uid()));
