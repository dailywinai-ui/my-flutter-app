-- Phase 1: media foundation for the day record (Win Daily 1.1.0).
-- Additive only. Existing rows and the live 1.0.x app are unaffected:
-- new columns default to empty/null and older builds ignore them.
-- Apply once in the Supabase SQL editor (or via the CLI) before testing
-- photo or voice builds. Nothing here deletes or rewrites data.

alter table public.daily_wins
  add column if not exists photo_paths text[] not null default '{}',
  add column if not exists tape_path text,
  add column if not exists reflection_audio_path text,
  add column if not exists place text;

-- Every screen looks wins up by user and date; index that path.
create index if not exists daily_wins_user_date_idx
  on public.daily_wins (user_id, win_date desc);

-- Private storage bucket for frames and tapes.
-- Object paths are "<user_id>/<win_id>/<file>", so the policies below
-- key on the first folder segment: a user can only touch their own.
insert into storage.buckets (id, name, public)
values ('day-media', 'day-media', false)
on conflict (id) do nothing;

drop policy if exists "day media read own" on storage.objects;
create policy "day media read own"
  on storage.objects for select
  using (bucket_id = 'day-media' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "day media insert own" on storage.objects;
create policy "day media insert own"
  on storage.objects for insert
  with check (bucket_id = 'day-media' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "day media update own" on storage.objects;
create policy "day media update own"
  on storage.objects for update
  using (bucket_id = 'day-media' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "day media delete own" on storage.objects;
create policy "day media delete own"
  on storage.objects for delete
  using (bucket_id = 'day-media' and (storage.foldername(name))[1] = auth.uid()::text);
