# Muhammad Ali Portfolio

Premium React + TypeScript + Vite portfolio for a Data Science & AI Developer.

## Local development

```bash
npm install
npm run dev
```

Production check: `npm run build` then `npm run preview`.

## Environment

Copy `.env.example` to `.env.local` and set `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, and `VITE_SITE_URL`. Never expose a Supabase service-role key in this frontend.

## Supabase

Run `supabase/schema.sql` in the Supabase SQL editor. It creates `projects`, `project_reviews`, RLS policies, and the `project-images` / `project-videos` storage buckets. Connect the admin CRUD and auth to these tables before production CMS use; the included `/admin` page is the visual CMS foundation.

After creating an admin account in Supabase Authentication, authorize it with:

```sql
insert into public.admin_users (user_id) values ('AUTH_USER_UUID');
```

The frontend checks both Supabase Auth and `admin_users`; RLS remains the enforcement layer for project/review/storage mutations. Use `/admin/login`, then `/admin/projects/new` to publish or save drafts. Public project data is fetched from Supabase when env variables are present; without them, the supplied CV projects are shown as a local fallback so the design remains previewable.

## Render / GitHub

Push the repository to GitHub. In Render choose **Static Site**, set build command to `npm run build`, publish directory to `dist`, and add the Vite environment variables. Add a rewrite from `/*` to `/index.html` so React Router deep links work on refresh.

The supplied profile image is used at `public/best.png`, and the intro video is served from `public/best.mp4`.
