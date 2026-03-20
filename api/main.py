from contextlib import asynccontextmanager
from typing import Optional
from fastapi import FastAPI
from pydantic import BaseModel
import bcrypt
from redis_client import init_redis, close_redis
from database import save_accounting, init_pool, close_pool, get_user_password, get_user_group, get_group_vlan, get_accounting_data

@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_pool()
    await init_redis()
    yield
    await close_pool()
    await close_redis()

class AuthRequest(BaseModel):
    username: str
    password: str
    
class AuthorizeRequest(BaseModel):
    username: str
    
class AccountingRequest(BaseModel):
    username:               str
    Acct_Status_Type:       str
    Acct_Session_Id:        str
    Acct_Unique_Session_Id: Optional[str] = None
    NAS_IP_Address:         Optional[str] = None
    NAS_Port_Id:            Optional[str] = None
    Acct_Session_Time:      Optional[int] = None
    Acct_Input_Octets:      Optional[int] = None
    Acct_Output_Octets:     Optional[int] = None
    Acct_Terminate_Cause:   Optional[str] = None
    Framed_IP_Address:      Optional[str] = None
    Calling_Station_Id:     Optional[str] = None

app = FastAPI(lifespan=lifespan)

@app.get("/health")
async def health_check():
    return {"status": "ok"}

@app.post("/auth")
async def auth(auth_request: AuthRequest):
    username = auth_request.username
    password = auth_request.password

    password_hash = await get_user_password(username)
    if password_hash is None:
        print(f"User not found: {username} {password}")
        return {"result": "reject"}
    elif password != password_hash:
        print(f"Invalid password for user: {username} {password}")
        return {"result": "reject"}
    else:
        print(f"Authentication successful for user: {username} {password}")
        return {"result": "accept"}

@app.post("/authorize")
async def authorize(authorize_request: AuthorizeRequest):
    username = authorize_request.username
    groupname = await get_user_group(username)
    print(f"User: {username}, Group: {groupname}")
    if groupname is None:
        return {"result": "Group not found"}
    vlan_id = await get_group_vlan(groupname)
    print(f"VLAN ID for group {groupname}: {vlan_id}")
    if vlan_id is None:
        return {"result": "VLAN ID not found"}
    return vlan_id 

@app.post("/accounting")
async def accounting(accounting_request: AccountingRequest):
    await save_accounting(accounting_request)
    return {"result": "ok"}


@app.get("/accounting/{username}")
async def get_accounting(username: str):
    data = await get_accounting_data(username)
    print(f"Accounting data for user {username}: {data}")
    return {"accounting_data": data}


