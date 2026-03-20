-- This SQL script initializes the PostgreSQL database by creating the necessary tables for the NAC system.

-- 'op' can be '==' for equality, ':=' for assignment, etc.
CREATE TABLE IF NOT EXISTS radcheck (
    id        SERIAL PRIMARY KEY,
    username  VARCHAR(32)  NOT NULL,
    attribute VARCHAR(64)  NOT NULL,
    op        VARCHAR(2)   NOT NULL,
    value     VARCHAR(253) NOT NULL
);

INSERT INTO radcheck (username, attribute, op, value) VALUES
    ('ahmet',   'Cleartext-Password', ':=', 'sifre123'),
    ('ayse',    'Cleartext-Password', ':=', 'sifre456'),
    ('misafir', 'Cleartext-Password', ':=', 'guest789'),
    ('health', 'Cleartext-Password', ':=', 'check');


CREATE TABLE IF NOT EXISTS radreply (
	id        SERIAL PRIMARY KEY,
	username  VARCHAR(32)  NOT NULL,
	attribute VARCHAR(64)  NOT NULL,
	op        VARCHAR(2)   NOT NULL,
	value     VARCHAR(253) NOT NULL
);

INSERT INTO radreply (username, attribute, op, value) VALUES
('health', 'Framed-IP-Address', ':=', '192.168.1.100');

CREATE TABLE IF NOT EXISTS radusergroup (
    id        SERIAL      PRIMARY KEY,
    username  VARCHAR(32) NOT NULL,
    groupname VARCHAR(64) NOT NULL,
    priority  INTEGER     DEFAULT 1
);

INSERT INTO radusergroup (username, groupname, priority) VALUES
('health', 'employee', 1),
('ahmet',   'admin',    2),
('ayse',    'employee', 3),
('misafir', 'guest',    4);


CREATE TABLE IF NOT EXISTS radgroupreply (
    id        SERIAL       PRIMARY KEY,
    groupname VARCHAR(64)  NOT NULL,
    attribute VARCHAR(64)  NOT NULL,
    op        VARCHAR(2)   NOT NULL,
    value     VARCHAR(253) NOT NULL
);

INSERT INTO radgroupreply (groupname, attribute, op, value) VALUES
('employee', 'Framed-IP-Address', ':=', '9'),
('admin',    'Tunnel-Type',             ':=', '13'),
('admin',    'Tunnel-Medium-Type',      ':=', '6'),
('admin',    'Tunnel-Private-Group-Id', ':=', '10'),

('employee', 'Tunnel-Type',             ':=', '13'),
('employee', 'Tunnel-Medium-Type',      ':=', '6'),
('employee', 'Tunnel-Private-Group-Id', ':=', '20'),

('guest',    'Tunnel-Type',             ':=', '13'),
('guest',    'Tunnel-Medium-Type',      ':=', '6'),
('guest',    'Tunnel-Private-Group-Id', ':=', '30');


CREATE TABLE IF NOT EXISTS radacct (
    id                  BIGSERIAL    PRIMARY KEY,
    acctsessionid       VARCHAR(64)  NOT NULL,        -- authorize identifier
    acctuniqueid        VARCHAR(32)  NOT NULL UNIQUE, -- unique identifier for each session
    username            VARCHAR(32)  NOT NULL,
    nasipaddress        INET         NOT NULL,         -- switch or router IP address
    nasportid           VARCHAR(15),                  -- which physical port was used
    acctstarttime       TIMESTAMPTZ,                  -- connection start time
    acctupdatetime      TIMESTAMPTZ,                  -- last update time
    acctstoptime        TIMESTAMPTZ,                  -- connection stop time
    acctsessiontime     INTEGER,                      -- total duration (seconds)
    acctinputoctets     BIGINT,                       -- data received from user
    acctoutputoctets    BIGINT,                       -- data sent to user
    acctterminatecause  VARCHAR(32),                  -- reason for termination
    framedipaddress     INET,                         -- user's IP address
    callingstationid    VARCHAR(50)                   -- MAC address
);

INSERT INTO radacct (
    acctsessionid, acctuniqueid, username, nasipaddress, nasportid,
    acctstarttime, acctupdatetime, acctstoptime, acctsessiontime,
    acctinputoctets, acctoutputoctets, acctterminatecause,
    framedipaddress, callingstationid
) VALUES
(
    'session001', 'unique001', 'ahmet', '192.168.1.1', 'eth0/1',
    '2026-03-20 08:00:00+00', '2026-03-20 08:30:00+00', '2026-03-20 09:00:00+00', 3600,
    10485760, 52428800, 'User-Request',
    '192.168.20.10', 'AA:BB:CC:DD:EE:FF'
),
(
    'session002', 'unique002', 'ayse', '192.168.1.1', 'eth0/2',
    '2026-03-20 09:00:00+00', '2026-03-20 09:15:00+00', NULL, 900,
    5242880, 20971520, NULL,
    '192.168.20.11', 'BB:CC:DD:EE:FF:AA'
),
(
    'session_health', 'unique_health', 'health', '127.0.0.1', 'eth0/0',
    '2026-03-20 00:00:00+00', NULL, NULL, NULL,
    NULL, NULL, NULL,
    '127.0.0.1', '00:00:00:00:00:00'
),
(
    'session003', 'unique003', 'misafir', '192.168.1.2', 'eth0/1',
    '2026-03-20 10:00:00+00', NULL, NULL, NULL,
    NULL, NULL, NULL,
    '192.168.30.10', 'CC:DD:EE:FF:AA:BB'
);

