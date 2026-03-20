# database.py
import asyncpg
import json

pool = None

async def init_pool():
    global pool
    pool = await asyncpg.create_pool(
        host     = "localhost",   # lokalde test için
        database = "radius",
        user     = "radius",
        password = "radius123",
        min_size = 2,
        max_size = 10
    )

async def close_pool():
    global pool
    if pool:
        await pool.close()

async def get_user_password(username: str):
    async with pool.acquire() as conn:
        row = await conn.fetchrow(
            "SELECT value FROM radcheck WHERE username = $1 AND attribute = 'Cleartext-Password'",
            username
        )
    return row["value"] if row else None

async def get_user_group(username: str):
	async with pool.acquire() as conn:
		row = await conn.fetchrow(
			"SELECT groupname FROM radusergroup WHERE username = $1",
			username
		)
	return row["groupname"] if row else None


async def get_group_vlan(groupname: str):
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            "SELECT groupname, attribute, value FROM radgroupreply WHERE groupname = $1",
            groupname
        )
    return {row["attribute"]: row["value"] for row in rows}

async def save_accounting(request):
    async with pool.acquire() as conn:
        if request.Acct_Status_Type == "Start":
            await conn.execute("""
                INSERT INTO radacct (
                    acctsessionid, acctuniqueid, username,
                    nasipaddress, nasportid,
                    acctstarttime, callingstationid, framedipaddress
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                ON CONFLICT (acctuniqueid) DO NOTHING
            """,
                request.Acct_Session_Id,
                request.Acct_Unique_Session_Id or request.Acct_Session_Id,
                request.username,
                request.NAS_IP_Address or "0.0.0.0",
                request.NAS_Port_Id,
                datetime.now(timezone.utc),
                request.Calling_Station_Id,
                request.Framed_IP_Address
            )
        elif request.Acct_Status_Type == "Interim-Update":
            await conn.execute("""
                UPDATE radacct SET
                    acctupdatetime   = $1,
                    acctsessiontime  = $2,
                    acctinputoctets  = $3,
                    acctoutputoctets = $4
                WHERE acctsessionid = $5
            """,
                datetime.now(timezone.utc),
                request.Acct_Session_Time,
                request.Acct_Input_Octets,
                request.Acct_Output_Octets,
                request.Acct_Session_Id
            )
        elif request.Acct_Status_Type == "Stop":
            await conn.execute("""
                UPDATE radacct SET
                    acctstoptime       = $1,
                    acctsessiontime    = $2,
                    acctinputoctets    = $3,
                    acctoutputoctets   = $4,
                    acctterminatecause = $5
                WHERE acctsessionid = $6
            """,
                datetime.now(timezone.utc),
                request.Acct_Session_Time,
                request.Acct_Input_Octets,
                request.Acct_Output_Octets,
                request.Acct_Terminate_Cause,
                request.Acct_Session_Id
            )

async def get_accounting_data(username: str):
    async with pool.acquire() as conn:
        rows = await conn.fetch(
            "SELECT * FROM radacct WHERE username = $1",
            username
        )
    return [dict(row) for row in rows]