-- table user
create table public.user_profile (
  id uuid primary key references auth.users(id),
  firstname text,
  lastname text,
  role_default text,
  points integer default 0,
  is_active boolean default true,
  created_at timestamptz default now()
);

--table role
CREATE TABLE role (
    id_role UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    description TEXT
);

-- Table user_role
 TABLE user_role (
    id_user UUID NOT NULL,
    id_role UUID NOT NULL,
    assigned_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (id_user, id_role),
    FOREIGN KEY (id_user) REFERENCES auth.users(id),
    FOREIGN KEY (id_role) REFERENCES role(id_role)
);

-- Table zone
CREATE TABLE zone (
    id_zone UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    population INTEGER,
    area_km2 NUMERIC(10,2),
    geom GEOMETRY(Point, 4326) -- assuming PostGIS
);

--table container_type
CREATE TABLE container_type (
    id_container_type UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20) NOT NULL,
    name VARCHAR(50) NOT NULL
);

--table container
CREATE TABLE container (
    id_container UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    uid VARCHAR(50) NOT NULL,
    capacity_l INTEGER,
    status VARCHAR(20),
    install_date TIMESTAMPTZ DEFAULT now(),
    id_zone UUID REFERENCES zone(id_zone),
    id_container_type UUID REFERENCES container_type(id_container_type),
    position GEOMETRY(Point, 4326)
);

--table device
CREATE TABLE device (
    id_device UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_uid VARCHAR(50) NOT NULL,
    model VARCHAR(50),
    firmware_version VARCHAR(20),
    last_seen TIMESTAMPTZ,
    id_container UUID REFERENCES container(id_container)
);

--table measurement
CREATE TABLE measurement (
    id_measurement UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fill_level_pct NUMERIC(5,2),
    battery_pct NUMERIC(5,2),
    temperature NUMERIC(5,2),
    recorded_at TIMESTAMPTZ DEFAULT now(),
    id_device UUID REFERENCES device(id_device),
    id_container UUID REFERENCES container(id_container)
);

--table vehicule
CREATE TABLE vehicle (
    id_vehicle UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    registration_number VARCHAR(20) NOT NULL,
    model VARCHAR(50),
    capacity_kg INTEGER
);

--table route
CREATE TABLE route (
    id_route UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20),
    date DATE,
    status VARCHAR(20),
    distance_m NUMERIC,
    duration_min NUMERIC,
    id_agent UUID REFERENCES auth.users(id),
    id_vehicle UUID REFERENCES vehicle(id_vehicle)
);

--table route_step
CREATE TABLE route_step (
    id_route_step UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sequence INTEGER,
    eta TIMESTAMPTZ,
    collected BOOLEAN DEFAULT false,
    id_route UUID REFERENCES route(id_route),
    id_container UUID REFERENCES container(id_container)
);

--table collection
CREATE TABLE collection (
    id_collection UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collected_at TIMESTAMPTZ DEFAULT now(),
    quantity_kg NUMERIC,
    sequence INTEGER,
    id_route UUID REFERENCES route(id_route),
    id_container UUID REFERENCES container(id_container)
);

--table maintenance
CREATE TABLE maintenance (
    id_maintenance UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    maintenance_type VARCHAR(50),
    status VARCHAR(20),
    scheduled_at TIMESTAMPTZ,
    performed_at TIMESTAMPTZ,
    id_container UUID REFERENCES container(id_container),
    id_device UUID REFERENCES device(id_device)
);

--table signalement_type
CREATE TABLE signalement_type (
    id_signalement_type UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    label VARCHAR(50),
    priority INTEGER,
    sla_hours INTEGER
);

--table signalement
CREATE TABLE signalement (
    id_signalement UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    description TEXT,
    photo_url TEXT,
    status VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT now(),
    id_signalement_type UUID REFERENCES signalement_type(id_signalement_type),
    id_container UUID REFERENCES container(id_container),
    id_user UUID REFERENCES auth.users(id)
);

--table signalement_treatment
CREATE TABLE signalement_treatment (
    id_treatment UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    treated_at TIMESTAMPTZ DEFAULT now(),
    comment TEXT,
    id_signalement UUID REFERENCES signalement(id_signalement),
    id_agent UUID REFERENCES auth.users(id)
);

--table badge
CREATE TABLE badge (
    id_badge UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(20),
    name VARCHAR(50),
    description TEXT
);

--table user_badge
CREATE TABLE user_badge (
    id_user_badge UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    earned_at TIMESTAMPTZ DEFAULT now(),
    id_user UUID REFERENCES auth.users(id),
    id_badge UUID REFERENCES badge(id_badge)
);

--table point_history
CREATE TABLE point_history (
    id_point_history UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    points_delta INTEGER,
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    id_user UUID REFERENCES auth.users(id)
);

--table notification
CREATE TABLE notification (
    id_notification UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(50),
    title VARCHAR(100),
    body TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    id_user UUID REFERENCES auth.users(id)
);

--table status_history
CREATE TABLE status_history (
    id_status_history UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50),
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    changed_at TIMESTAMPTZ DEFAULT now(),
    entity_id UUID
);

--table audit_log
CREATE TABLE audit_log (
    id_audit_log UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES auth.users(id),
    action VARCHAR(100),
    entity_type VARCHAR(50),
    entity_id UUID,
    created_at TIMESTAMPTZ DEFAULT now()
);

alter table container
drop column position;

alter table container
add column position geography(Point, 4326) not null;
