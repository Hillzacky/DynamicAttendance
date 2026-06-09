-- Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis"; -- untuk koordinat

-- =============================================
-- TABLE: clients
-- =============================================
CREATE TABLE IF NOT EXISTS clients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(150) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  address TEXT,
  phone VARCHAR(20),
  email VARCHAR(100),
  logo_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- TABLE: departments
-- =============================================
CREATE TABLE IF NOT EXISTS departments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  name VARCHAR(150) NOT NULL,
  code VARCHAR(50),
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- TABLE: positions
-- =============================================
CREATE TABLE IF NOT EXISTS positions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  name VARCHAR(150) NOT NULL,
  code VARCHAR(50),
  level INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- TABLE: users
-- =============================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  fullname VARCHAR(150) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  kontak VARCHAR(20),
  nip VARCHAR(50) UNIQUE,
  client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  position_id UUID REFERENCES positions(id) ON DELETE SET NULL,
  no_bpjs VARCHAR(50),
  no_jmo VARCHAR(50),
  status VARCHAR(20) DEFAULT 'active' 
    CHECK (status IN ('active', 'inactive', 'suspended', 'resigned')),
  role VARCHAR(20) DEFAULT 'employee'
    CHECK (role IN ('superadmin', 'admin', 'hr', 'employee')),
  device_id VARCHAR(255),
  device_name VARCHAR(100),
  device_platform VARCHAR(20),
  avatar_url TEXT,
  last_login TIMESTAMP WITH TIME ZONE,
  email_verified_at TIMESTAMP WITH TIME ZONE,
  password_reset_token VARCHAR(255),
  password_reset_expires TIMESTAMP WITH TIME ZONE,
  refresh_token TEXT,
  is_online BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index users
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_nip ON users(nip);
CREATE INDEX idx_users_client_id ON users(client_id);
CREATE INDEX idx_users_department_id ON users(department_id);
CREATE INDEX idx_users_status ON users(status);

-- =============================================
-- TABLE: shifts
-- =============================================
CREATE TABLE IF NOT EXISTS shifts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50),
  check_in_time TIME NOT NULL,
  check_out_time TIME NOT NULL,
  late_tolerance INTEGER DEFAULT 0, -- dalam menit
  early_leave_tolerance INTEGER DEFAULT 0, -- dalam menit
  is_overnight BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- TABLE: locations (Kantor/Titik Absensi)
-- =============================================
CREATE TABLE IF NOT EXISTS locations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  name VARCHAR(150) NOT NULL,
  code VARCHAR(50),
  address TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  radius INTEGER NOT NULL DEFAULT 100, -- dalam meter
  geom GEOMETRY(Point, 4326),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index locations
CREATE INDEX idx_locations_client_id ON locations(client_id);
CREATE INDEX idx_locations_geom ON locations USING GIST(geom);

-- Trigger update geom otomatis
CREATE OR REPLACE FUNCTION update_location_geom()
RETURNS TRIGGER AS $$BEGIN
  NEW.geom = ST_SetSRID(
    ST_MakePoint(NEW.longitude, NEW.latitude), 4326
  );
  RETURN NEW;
END;$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_location_geom
BEFORE INSERT OR UPDATE ON locations
FOR EACH ROW EXECUTE FUNCTION update_location_geom();

-- =============================================
-- TABLE: attendances
-- =============================================
CREATE TABLE IF NOT EXISTS attendances (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
  shift_id UUID REFERENCES shifts(id) ON DELETE SET NULL,
  attendance_date DATE NOT NULL,
  type VARCHAR(10) NOT NULL 
    CHECK (type IN ('check_in', 'check_out')),
  attendance_mode VARCHAR(10) NOT NULL DEFAULT 'current'
    CHECK (attendance_mode IN ('current', 'manual')),
  attendance_time TIMESTAMP WITH TIME ZONE NOT NULL,
  photo_url TEXT,
  
  -- Koordinat Karyawan
  employee_latitude DOUBLE PRECISION,
  employee_longitude DOUBLE PRECISION,
  employee_geom GEOMETRY(Point, 4326),
  
  -- Koordinat Kantor
  office_latitude DOUBLE PRECISION,
  office_longitude DOUBLE PRECISION,
  
  -- Jarak & Radius
  distance_meter DOUBLE PRECISION,
  radius_meter INTEGER,
  is_within_radius BOOLEAN DEFAULT FALSE,
  
  -- Status
  status VARCHAR(20) DEFAULT 'present'
    CHECK (status IN (
      'present', 'late', 'early_leave', 
      'absent', 'pending', 'rejected', 'approved'
    )),
  
  -- Manual Attendance
  manual_date DATE,
  manual_time TIME,
  manual_reason TEXT,
  approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
  approved_at TIMESTAMP WITH TIME ZONE,
  
  -- Notes
  notes TEXT,
  
  -- Device Info
  device_id VARCHAR(255),
  device_name VARCHAR(100),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Unique constraint: 1 karyawan hanya bisa 1x check_in dan 1x check_out per hari
  UNIQUE(user_id, attendance_date, type, attendance_mode)
);

-- Index attendances
CREATE INDEX idx_attendances_user_id ON attendances(user_id);
CREATE INDEX idx_attendances_client_id ON attendances(client_id);
CREATE INDEX idx_attendances_date ON attendances(attendance_date);
CREATE INDEX idx_attendances_type ON attendances(type);
CREATE INDEX idx_attendances_status ON attendances(status);
CREATE INDEX idx_attendances_geom ON attendances USING GIST(employee_geom);

-- Trigger update geom
CREATE OR REPLACE FUNCTION update_attendance_geom()
RETURNS TRIGGER AS $$BEGIN
  IF NEW.employee_latitude IS NOT NULL 
    AND NEW.employee_longitude IS NOT NULL THEN
    NEW.employee_geom = ST_SetSRID(
      ST_MakePoint(NEW.employee_longitude, NEW.employee_latitude), 4326
    );
  END IF;
  RETURN NEW;
END;$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_attendance_geom
BEFORE INSERT OR UPDATE ON attendances
FOR EACH ROW EXECUTE FUNCTION update_attendance_geom();

-- =============================================
-- TABLE: leave_types (Jenis Cuti/Izin)
-- =============================================
CREATE TABLE IF NOT EXISTS leave_types (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50) NOT NULL,
  max_days INTEGER DEFAULT 0,
  is_paid BOOLEAN DEFAULT TRUE,
  requires_document BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert Default Leave Types (Lanjutan)
INSERT INTO leave_types (name, code, max_days, is_paid, requires_document) VALUES
  ('Cuti Tahunan', 'ANNUAL_LEAVE', 12, TRUE, FALSE),
  ('Sakit', 'SICK_LEAVE', 0, TRUE, TRUE),
  ('Cuti Melahirkan', 'MATERNITY_LEAVE', 90, TRUE, TRUE),
  ('Cuti Istri Melahirkan', 'PATERNITY_LEAVE', 3, TRUE, FALSE),
  ('Cuti Keluarga Meninggal (I/S/A/OT)', 'BEREAVEMENT_LEAVE', 3, TRUE, TRUE),
  ('Cuti Menikah', 'MARRIAGE_LEAVE', 3, TRUE, TRUE);

-- =============================================
-- TABLE: leaves (Data Cuti/Izin/Sakit)
-- =============================================
CREATE TABLE IF NOT EXISTS leaves (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  leave_type_id UUID NOT NULL REFERENCES leave_types(id) ON DELETE RESTRICT,
  
  -- Tanggal
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_days INTEGER NOT NULL DEFAULT 1,
  
  -- Status
  status VARCHAR(20) DEFAULT 'pending'
    CHECK (status IN (
      'pending', 'approved', 'rejected', 'cancelled'
    )),
  
  -- Dokumen
  document_url TEXT,
  document_type VARCHAR(10)
    CHECK (document_type IN ('image', 'pdf', NULL)),
  
  -- Notes
  notes TEXT,
  rejection_reason TEXT,
  
  -- Approval
  approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
  approved_at TIMESTAMP WITH TIME ZONE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index leaves
CREATE INDEX idx_leaves_user_id ON leaves(user_id);
CREATE INDEX idx_leaves_client_id ON leaves(client_id);
CREATE INDEX idx_leaves_leave_type_id ON leaves(leave_type_id);
CREATE INDEX idx_leaves_start_date ON leaves(start_date);
CREATE INDEX idx_leaves_end_date ON leaves(end_date);
CREATE INDEX idx_leaves_status ON leaves(status);

-- =============================================
-- TABLE: user_shifts (Jadwal Shift Karyawan)
-- =============================================
CREATE TABLE IF NOT EXISTS user_shifts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  shift_id UUID NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  effective_date DATE NOT NULL,
  end_date DATE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index user_shifts
CREATE INDEX idx_user_shifts_user_id ON user_shifts(user_id);
CREATE INDEX idx_user_shifts_shift_id ON user_shifts(shift_id);
CREATE INDEX idx_user_shifts_effective_date ON user_shifts(effective_date);

-- =============================================
-- TABLE: user_locations (Lanjutan)
-- =============================================
CREATE TABLE IF NOT EXISTS user_locations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  is_primary BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, location_id)
);

-- Index user_locations
CREATE INDEX idx_user_locations_user_id ON user_locations(user_id);
CREATE INDEX idx_user_locations_location_id ON user_locations(location_id);

-- =============================================
-- TABLE: notifications
-- =============================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(150) NOT NULL,
  body TEXT NOT NULL,
  type VARCHAR(50) NOT NULL
    CHECK (type IN (
      'attendance', 'leave', 'manual_attendance',
      'approval', 'announcement', 'system'
    )),
  reference_id UUID,
  reference_type VARCHAR(50),
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index notifications
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- =============================================
-- TABLE: audit_logs
-- =============================================
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  action VARCHAR(100) NOT NULL,
  table_name VARCHAR(100),
  record_id UUID,
  old_values JSONB,
  new_values JSONB,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index audit_logs
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_table_name ON audit_logs(table_name);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- =============================================
-- FUNCTION: updated_at trigger
-- =============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;$$LANGUAGE plpgsql;

-- Apply updated_at trigger to all tables
DO$$DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'clients', 'departments', 'positions', 'users',
    'shifts', 'locations', 'attendances', 'leave_types',
    'leaves', 'user_shifts', 'user_locations', 'notifications'
  ]
  LOOP
    EXECUTE format('
      CREATE TRIGGER trigger_update_%I_updated_at
      BEFORE UPDATE ON %I
      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    ', t, t);
  END LOOP;
END;$$;

-- =============================================
-- FUNCTION: Calculate Distance (Haversine) Lanjutan
-- =============================================
CREATE OR REPLACE FUNCTION calculate_distance_meter(
  lat1 DOUBLE PRECISION,
  lon1 DOUBLE PRECISION,
  lat2 DOUBLE PRECISION,
  lon2 DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION AS $$DECLARE
  r DOUBLE PRECISION := 6371000; -- radius bumi dalam meter
  phi1 DOUBLE PRECISION;
  phi2 DOUBLE PRECISION;
  dphi DOUBLE PRECISION;
  dlambda DOUBLE PRECISION;
  a DOUBLE PRECISION;
  c DOUBLE PRECISION;
BEGIN
  phi1 := radians(lat1);
  phi2 := radians(lat2);
  dphi := radians(lat2 - lat1);
  dlambda := radians(lon2 - lon1);
  
  a := sin(dphi/2)^2 + 
       cos(phi1) * cos(phi2) * sin(dlambda/2)^2;
  c := 2 * atan2(sqrt(a), sqrt(1-a));
  
  RETURN r * c;
END;$$LANGUAGE plpgsql IMMUTABLE;

-- =============================================
-- FUNCTION: Check Attendance Within Radius
-- =============================================
CREATE OR REPLACE FUNCTION check_attendance_radius(
  emp_lat DOUBLE PRECISION,
  emp_lon DOUBLE PRECISION,
  office_lat DOUBLE PRECISION,
  office_lon DOUBLE PRECISION,
  radius_meter INTEGER
)
RETURNS TABLE (
  distance DOUBLE PRECISION,
  is_within BOOLEAN
) AS$$BEGIN
  RETURN QUERY
  SELECT 
    calculate_distance_meter(emp_lat, emp_lon, office_lat, office_lon),
    calculate_distance_meter(emp_lat, emp_lon, office_lat, office_lon) <= radius_meter;
END;$$LANGUAGE plpgsql;

-- =============================================
-- FUNCTION: Get User Attendance Summary
-- =============================================
CREATE OR REPLACE FUNCTION get_attendance_summary(
  p_user_id UUID,
  p_month INTEGER,
  p_year INTEGER
)
RETURNS TABLE (
  total_present INTEGER,
  total_late INTEGER,
  total_absent INTEGER,
  total_leave INTEGER,
  total_sick INTEGER,
  total_permit INTEGER,
  total_working_days INTEGER
) AS$$
BEGIN
  RETURN QUERY
  WITH attendance_data AS (
    SELECT 
      a.attendance_date,
      a.status,
      a.type
    FROM attendances a
    WHERE a.user_id = p_user_id
      AND EXTRACT(MONTH FROM a.attendance_date) = p_month
      AND EXTRACT(YEAR FROM a.attendance_date) = p_year
      AND a.type = 'check_in'
  ),
  leave_data AS (
    SELECT 
      generate_series(l.start_date, l.end_date, '1 day'::interval)::date AS leave_date,
      lt.code AS leave_code
    FROM leaves l
    JOIN leave_types lt ON l.leave_type_id = lt.id
    WHERE l.user_id = p_user_id
      AND l.status = 'approved'
      AND EXTRACT(MONTH FROM l.start_date) = p_month
      AND EXTRACT(YEAR FROM l.start_date) = p_year
  )
  SELECT
    COUNT(DISTINCT CASE WHEN ad.status = 'present' 
      THEN ad.attendance_date END)::INTEGER AS total_present,
    COUNT(DISTINCT CASE WHEN ad.status = 'late' 
      THEN ad.attendance_date END)::INTEGER AS total_late,
    COUNT(DISTINCT CASE WHEN ad.status = 'absent' 
      THEN ad.attendance_date END)::INTEGER AS total_absent,
    COUNT(DISTINCT CASE WHEN ld.leave_code = 'ANNUAL_LEAVE' 
      THEN ld.leave_date END)::INTEGER AS total_leave,
    COUNT(DISTINCT CASE WHEN ld.leave_code = 'SICK_LEAVE' 
      THEN ld.leave_date END)::INTEGER AS total_sick,
    COUNT(DISTINCT CASE WHEN ld.leave_code NOT IN (
      'ANNUAL_LEAVE', 'SICK_LEAVE'
    ) THEN ld.leave_date END)::INTEGER AS total_permit,
    (
      SELECT COUNT(*)::INTEGER
      FROM generate_series(
        DATE_TRUNC('month', MAKE_DATE(p_year, p_month, 1)),
        DATE_TRUNC('month', MAKE_DATE(p_year, p_month, 1)) 
          + INTERVAL '1 month' - INTERVAL '1 day',
        '1 day'::interval
      ) AS d(day)
      WHERE EXTRACT(DOW FROM d.day) NOT IN (0, 6)
    ) AS total_working_days
  FROM attendance_data ad
  FULL OUTER JOIN leave_data ld ON ad.attendance_date = ld.leave_date;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- VIEW: v_attendance_detail
-- =============================================
CREATE OR REPLACE VIEW v_attendance_detail AS
SELECT
  a.id,
  a.user_id,
  u.fullname AS employee_name,
  u.nip,
  c.name AS client_name,
  d.name AS department_name,
  p.name AS position_name,
  l.name AS location_name,
  l.address AS location_address,
  s.name AS shift_name,
  s.check_in_time,
  s.check_out_time,
  a.attendance_date,
  a.type,
  a.attendance_mode,
  a.attendance_time,
  a.photo_url,
  a.employee_latitude,
  a.employee_longitude,
  a.office_latitude,
  a.office_longitude,
  a.distance_meter,
  a.radius_meter,
  a.is_within_radius,
  a.status,
  a.manual_date,
  a.manual_time,
  a.manual_reason,
  a.notes,
  a.device_id,
  a.device_name,
  a.created_at,
  a.updated_at
FROM attendances a
JOIN users u ON a.user_id = u.id
JOIN clients c ON a.client_id = c.id
LEFT JOIN departments d ON u.department_id = d.id
LEFT JOIN positions p ON u.position_id = p.id
LEFT JOIN locations l ON a.location_id = l.id
LEFT JOIN shifts s ON a.shift_id = s.id;

-- =============================================
-- VIEW: v_leave_detail
-- =============================================
CREATE OR REPLACE VIEW v_leave_detail AS
SELECT
  l.id,
  l.user_id,
  u.fullname AS employee_name,
  u.nip,
  c.name AS client_name,
  d.name AS department_name,
  lt.name AS leave_type_name,
  lt.code AS leave_type_code,
  lt.is_paid,
  l.start_date,
  l.end_date,
  l.total_days,
  l.status,
  l.document_url,
  l.document_type,
  l.notes,
  l.rejection_reason,
  approver.fullname AS approved_by_name,
  l.approved_at,
  l.created_at,
  l.updated_at
FROM leaves l
JOIN users u ON l.user_id = u.id
JOIN clients c ON l.client_id = c.id
LEFT JOIN departments d ON u.department_id = d.id
LEFT JOIN leave_types lt ON l.leave_type_id = lt.id
LEFT JOIN users approver ON l.approved_by = approver.id;

-- =============================================
-- VIEW: v_user_detail
-- =============================================
CREATE OR REPLACE VIEW v_user_detail AS
SELECT
  u.id,
  u.username,
  u.fullname,
  u.email,
  u.kontak,
  u.nip,
  u.no_bpjs,
  u.no_jmo,
  u.status,
  u.role,
  u.avatar_url,
  u.device_id,
  u.device_name,
  u.device_platform,
  u.last_login,
  u.is_online,
  c.id AS client_id,
  c.name AS client_name,
  c.code AS client_code,
  d.id AS department_id,
  d.name AS department_name,
  p.id AS position_id,
  p.name AS position_name,
  p.level AS position_level,
  u.created_at,
  u.updated_at
FROM users u
LEFT JOIN clients c ON u.client_id = c.id
LEFT JOIN departments d ON u.department_id = d.id
LEFT JOIN positions p ON u.position_id = p.id;

-- =============================================
-- SEED: Default Admin User
-- =============================================
INSERT INTO clients (id, name, code, address, phone, email)
VALUES (
  uuid_generate_v4(),
  'PT. Default Company',
  'DEFAULT',
  'Jl. Default No. 1',
  '021-0000000',
  'admin@default.com'
) ON CONFLICT DO NOTHING;

INSERT INTO users (
  username, password, fullname, email,
  kontak, nip, role, status,
  client_id
)
SELECT
  'superadmin',
  -- password: Admin@123 (bcrypt)
  '$2b$10$rJ9/k5VGqZIH4TlV.VVlXOGH0SqXHEqp5FBgNH.pPl3Y2UyFbhG6a',
  'Super Administrator',
  'superadmin@attendance.app',
  '08000000000',
  'SA-001',
  'superadmin',
  'active',
  id
FROM clients
WHERE code = 'DEFAULT'
ON CONFLICT DO NOTHING;