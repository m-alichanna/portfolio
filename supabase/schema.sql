create extension if not exists pgcrypto;
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade
);
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(), slug text unique not null, title text not null,
  category text not null, short_description text, description text, thumbnail_url text,
  screenshots text[] default '{}', video_url text, github_url text, live_demo_url text,
  technologies text[] default '{}', published boolean default false, featured boolean default false,
  created_at timestamptz default now(), updated_at timestamptz default now()
);
create table if not exists public.project_reviews (
  id uuid primary key default gen_random_uuid(), project_id uuid references public.projects(id) on delete cascade not null,
  name text not null, email text not null, rating int check (rating between 1 and 5),
  comment text not null, created_at timestamptz default now(), unique(project_id, email)
);
do $$ begin
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='project_reviews' and column_name='visitor_name') then
    alter table public.project_reviews rename column visitor_name to name;
  end if;
  if exists (select 1 from information_schema.columns where table_schema='public' and table_name='project_reviews' and column_name='visitor_email') then
    alter table public.project_reviews rename column visitor_email to email;
  end if;
  if exists (select 1 from pg_constraint where conrelid = 'public.project_reviews'::regclass and conname = 'project_reviews_project_id_visitor_email_key') then
    alter table public.project_reviews drop constraint project_reviews_project_id_visitor_email_key;
  end if;
  if not exists (select 1 from pg_constraint where conrelid = 'public.project_reviews'::regclass and conname = 'project_reviews_project_id_email_key') then
    alter table public.project_reviews add constraint project_reviews_project_id_email_key unique (project_id, email);
  end if;
end $$;
insert into storage.buckets (id, name, public) values ('project-images','project-images',true),('project-videos','project-videos',true) on conflict (id) do nothing;
alter table public.projects enable row level security;
alter table public.project_reviews enable row level security;
alter table public.admin_users enable row level security;
drop policy if exists "Admins can read admin users" on public.admin_users;
drop policy if exists "Published projects are public" on public.projects;
drop policy if exists "Admins can manage projects" on public.projects;
drop policy if exists "Reviews are public" on public.project_reviews;
drop policy if exists "Visitors can submit reviews" on public.project_reviews;
drop policy if exists "Admins can read reviews" on public.project_reviews;
drop policy if exists "Admins can manage reviews" on public.project_reviews;
drop policy if exists "Admins can manage project images" on storage.objects;
drop policy if exists "Admins can manage project videos" on storage.objects;
create or replace function public.is_admin() returns boolean language sql security definer set search_path = public as $$
  select exists (select 1 from public.admin_users where user_id = auth.uid());
$$;
create policy "Admins can read admin users" on public.admin_users for select using (auth.uid() = user_id);
create policy "Published projects are public" on public.projects for select using (published = true);
create policy "Admins can manage projects" on public.projects for all using (public.is_admin()) with check (public.is_admin());
create policy "Admins can read reviews" on public.project_reviews for select using (public.is_admin());
create policy "Visitors can submit reviews" on public.project_reviews for insert with check (true);
create policy "Admins can manage reviews" on public.project_reviews for delete using (public.is_admin());
create policy "Admins can manage project images" on storage.objects for all using (bucket_id = 'project-images' and public.is_admin()) with check (bucket_id = 'project-images' and public.is_admin());
create policy "Admins can manage project videos" on storage.objects for all using (bucket_id = 'project-videos' and public.is_admin()) with check (bucket_id = 'project-videos' and public.is_admin());
create or replace function public.touch_project_updated_at() returns trigger language plpgsql as $$ begin new.updated_at = now(); return new; end; $$;
drop trigger if exists projects_updated_at on public.projects;
create trigger projects_updated_at before update on public.projects for each row execute function public.touch_project_updated_at();
drop view if exists public.project_reviews_public;
create view public.project_reviews_public with (security_invoker = false) as
  select id, project_id, name, rating, comment, created_at from public.project_reviews;
grant select on public.project_reviews_public to anon, authenticated;
