-- 'op' can be '==' for equality, ':=' for assignment, etc.
CREATE TABLE IF NOT EXISTS radcheck (
    id        SERIAL PRIMARY KEY,
    username  VARCHAR(32)  NOT NULL,
    attribute VARCHAR(64)  NOT NULL,
    op        VARCHAR(2)   NOT NULL,
    value     VARCHAR(253) NOT NULL
);

INSERT INTO radcheck (username, attribute, op, value) VALUES
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
	id        SERIAL PRIMARY KEY,
	username  VARCHAR(32)  NOT NULL,
	groupname VARCHAR(64)  NOT NULL,
	priority  INTEGER       NOT NULL
);

CREATE TABLE IF NOT EXISTS radusergroup (
    id        SERIAL      PRIMARY KEY,
    username  VARCHAR(32) NOT NULL,
    groupname VARCHAR(64) NOT NULL,
    priority  INTEGER     DEFAULT 1
);

INSERT INTO radusergroup (username, groupname, priority) VALUES
('health', 'employee', 1);

CREATE TABLE IF NOT EXISTS radgroupreply (
    id        SERIAL       PRIMARY KEY,
    groupname VARCHAR(64)  NOT NULL,
    attribute VARCHAR(64)  NOT NULL,
    op        VARCHAR(2)   NOT NULL,
    value     VARCHAR(253) NOT NULL
);

INSERT INTO radgroupreply (groupname, attribute, op, value) VALUES
('employee', 'Framed-IP-Address', ':=', '192.168.1.100');

CREATE TABLE IF NOT EXISTS radacct (
    id                  BIGSERIAL    PRIMARY KEY,
    acctsessionid       VARCHAR(64)  NOT NULL,        
    acctuniqueid        VARCHAR(32)  NOT NULL UNIQUE, 
    username            VARCHAR(32)  NOT NULL,
    nasipaddress        INET         NOT NULL,         
    nasportid           VARCHAR(15),                  
    acctstarttime       TIMESTAMPTZ,                  
    acctupdatetime      TIMESTAMPTZ,                  
    acctstoptime        TIMESTAMPTZ,                  
    acctsessiontime     INTEGER,                      
    acctinputoctets     BIGINT,                       
    acctoutputoctets    BIGINT,                       
    acctterminatecause  VARCHAR(32),                  
    framedipaddress     INET,                         
    callingstationid    VARCHAR(50)                   
);
