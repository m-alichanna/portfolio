export type ProjectRow = {
  id: string
  slug: string
  title: string
  category: string
  short_description: string | null
  description: string | null
  thumbnail_url: string | null
  screenshots: string[] | null
  video_url: string | null
  github_url: string | null
  live_demo_url: string | null
  technologies: string[] | null
  published: boolean
  featured: boolean
  created_at: string
  updated_at: string
}
export type ReviewRow = { id: string; project_id: string; name: string; email: string; rating: number; comment: string; created_at: string }
export type Database = { public: { Tables: { projects: { Row: ProjectRow; Insert: Partial<ProjectRow> & Pick<ProjectRow,'slug'|'title'|'category'>; Update: Partial<ProjectRow> }; project_reviews: { Row: ReviewRow; Insert: Omit<ReviewRow,'id'|'created_at'>; Update: Partial<ReviewRow> }; admin_users: { Row: { user_id: string }; Insert: { user_id: string }; Update: { user_id?: string } } } } }
