-- ShareTrip Supabase schema. Run in Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 email text, full_name text not null default '', role text not null check (role in ('student','driver')),
 avatar_url text, details jsonb not null default '{}'::jsonb, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.rides (
 id uuid primary key default gen_random_uuid(), driver_id uuid not null references public.profiles(id) on delete cascade,
 pickup text not null, destination text not null, departure_at timestamptz not null,
 seats_available int not null check(seats_available > 0), vehicle_type text not null check(vehicle_type in ('Shuttle','Motorcycle','Tricycle')),
 fare numeric(10,2) not null default 0, status text not null default 'open' check(status in ('open','full','cancelled','completed')),
 created_at timestamptz not null default now()
);
create table if not exists public.ride_requests (
 id uuid primary key default gen_random_uuid(), ride_id uuid not null references public.rides(id) on delete cascade,
 student_id uuid not null references public.profiles(id) on delete cascade, note text, status text not null default 'pending' check(status in ('pending','accepted','declined','cancelled')),
 created_at timestamptz not null default now(), unique(ride_id,student_id)
);
create table if not exists public.conversations (
 id uuid primary key default gen_random_uuid(), ride_id uuid references public.rides(id) on delete set null,
 student_id uuid not null references public.profiles(id) on delete cascade,
 driver_id uuid not null references public.profiles(id) on delete cascade, created_at timestamptz not null default now(), unique(ride_id,student_id,driver_id)
);
create table if not exists public.messages (
 id uuid primary key default gen_random_uuid(), conversation_id uuid not null references public.conversations(id) on delete cascade,
 sender_id uuid not null references public.profiles(id) on delete cascade, body text not null check(length(trim(body)) between 1 and 4000), created_at timestamptz not null default now()
);
create table if not exists public.driver_locations (
 driver_id uuid primary key references public.profiles(id) on delete cascade,
 ride_id uuid references public.rides(id) on delete set null, latitude double precision not null check(latitude between -90 and 90),
 longitude double precision not null check(longitude between -180 and 180), accuracy_m double precision, updated_at timestamptz not null default now()
);
create table if not exists public.emergency_alerts (
 id uuid primary key default gen_random_uuid(), reporter_id uuid not null references public.profiles(id) on delete cascade,
 message text not null, latitude double precision not null, longitude double precision not null,
 status text not null default 'open', created_at timestamptz not null default now()
);
create table if not exists public.device_tokens (
 user_id uuid not null references public.profiles(id) on delete cascade, token text not null,
 platform text not null check(platform in ('android','ios','web')), updated_at timestamptz not null default now(), primary key(user_id,token)
);

alter table public.profiles enable row level security;
alter table public.rides enable row level security;
alter table public.ride_requests enable row level security;
alter table public.conversations enable row level security;
alter table public.messages enable row level security;
alter table public.driver_locations enable row level security;
alter table public.emergency_alerts enable row level security;
alter table public.device_tokens enable row level security;

create policy "profiles readable to authenticated users" on public.profiles for select to authenticated using (true);
create policy "users insert own profile" on public.profiles for insert to authenticated with check (id = auth.uid());
create policy "users update own profile" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "authenticated users read open rides" on public.rides for select to authenticated using (status = 'open' or driver_id = auth.uid());
create policy "drivers create own rides" on public.rides for insert to authenticated with check (driver_id = auth.uid() and exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='driver'));
create policy "drivers update own rides" on public.rides for update to authenticated using (driver_id=auth.uid()) with check (driver_id=auth.uid());
create policy "students create own requests" on public.ride_requests for insert to authenticated with check (student_id=auth.uid() and exists(select 1 from public.profiles p where p.id=auth.uid() and p.role='student'));
create policy "request participants read requests" on public.ride_requests for select to authenticated using (student_id=auth.uid() or exists(select 1 from public.rides r where r.id=ride_id and r.driver_id=auth.uid()));
create policy "ride driver updates requests" on public.ride_requests for update to authenticated using (exists(select 1 from public.rides r where r.id=ride_id and r.driver_id=auth.uid())) with check (exists(select 1 from public.rides r where r.id=ride_id and r.driver_id=auth.uid()));
create policy "conversation participants read" on public.conversations for select to authenticated using (student_id=auth.uid() or driver_id=auth.uid());
create policy "student creates conversation for ride" on public.conversations for insert to authenticated with check (student_id=auth.uid() and exists(select 1 from public.rides r where r.id=ride_id and r.driver_id=driver_id));
create policy "participants read messages" on public.messages for select to authenticated using (exists(select 1 from public.conversations c where c.id=conversation_id and (c.student_id=auth.uid() or c.driver_id=auth.uid())));
create policy "participants send messages" on public.messages for insert to authenticated with check (sender_id=auth.uid() and exists(select 1 from public.conversations c where c.id=conversation_id and (c.student_id=auth.uid() or c.driver_id=auth.uid())));
create policy "driver manages own location" on public.driver_locations for all to authenticated using (driver_id=auth.uid()) with check (driver_id=auth.uid());
create policy "ride student can view driver location" on public.driver_locations for select to authenticated using (exists(select 1 from public.ride_requests rr where rr.ride_id=driver_locations.ride_id and rr.student_id=auth.uid() and rr.status='accepted'));
create policy "user creates own emergency alert" on public.emergency_alerts for insert to authenticated with check (reporter_id=auth.uid());
create policy "user reads own emergency alerts" on public.emergency_alerts for select to authenticated using (reporter_id=auth.uid());
create policy "user manages own device tokens" on public.device_tokens for all to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());

insert into storage.buckets(id,name,public) values ('profile-photos','profile-photos',true) on conflict(id) do nothing;
create policy "profile photo owner upload" on storage.objects for insert to authenticated with check (bucket_id='profile-photos' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "profile photos public read" on storage.objects for select to public using (bucket_id='profile-photos');
create policy "profile photo owner update" on storage.objects for update to authenticated using (bucket_id='profile-photos' and (storage.foldername(name))[1]=auth.uid()::text) with check (bucket_id='profile-photos' and (storage.foldername(name))[1]=auth.uid()::text);


-- Create a profile automatically at signup, including when email confirmation is enabled.
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
 insert into public.profiles(id,email,full_name,role)
 values(new.id,new.email,coalesce(new.raw_user_meta_data->>'full_name',''),
   case when new.raw_user_meta_data->>'role' in ('student','driver') then new.raw_user_meta_data->>'role' else 'student' end)
 on conflict(id) do update set email=excluded.email, full_name=excluded.full_name, role=excluded.role;
 return new;
end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();


-- Student's live pickup location, visible only to the driver on their accepted ride request.
create table if not exists public.student_locations (
 student_id uuid primary key references public.profiles(id) on delete cascade,
 ride_id uuid not null references public.rides(id) on delete cascade,
 latitude double precision not null check(latitude between -90 and 90),
 longitude double precision not null check(longitude between -180 and 180),
 accuracy_m double precision,
 updated_at timestamptz not null default now()
);
alter table public.student_locations enable row level security;
create policy "students publish own live pickup location" on public.student_locations
 for all to authenticated using(student_id=auth.uid())
 with check(student_id=auth.uid() and exists(
   select 1 from public.ride_requests rr
   where rr.ride_id=student_locations.ride_id and rr.student_id=auth.uid()
     and rr.status in ('pending','accepted')
 ));
create policy "assigned driver can view waiting student location" on public.student_locations
 for select to authenticated using(exists(
   select 1 from public.ride_requests rr join public.rides r on r.id=rr.ride_id
   where rr.ride_id=student_locations.ride_id and rr.student_id=student_locations.student_id
     and r.driver_id=auth.uid() and rr.status in ('pending','accepted')
 ));

-- Realtime subscriptions used by student/driver live tracking and chat.
-- Run once; duplicate publication membership is ignored.
do $$
begin
  alter publication supabase_realtime add table public.student_locations;
exception when duplicate_object then null;
end $$;
do $$
begin
  alter publication supabase_realtime add table public.driver_locations;
exception when duplicate_object then null;
end $$;
do $$
begin
  alter publication supabase_realtime add table public.messages;
exception when duplicate_object then null;
end $$;
