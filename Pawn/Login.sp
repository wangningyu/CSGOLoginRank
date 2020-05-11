/*
	玩家进服后自动注册与登录
	获取reg表权限
*/
#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>
#include <sdkhooks>

#define MAXENTITIES 	1024
#define MAX_FILE_LEN 	180
#define _DEBUG

#define TABLE_LOGIN		"csgo_member"
#define TABLE_FLAG		"csgo_flag"

#define is_player(%1) 	IsClientInGame(%1)

new String:szError[255]
new Handle:hDatabase = INVALID_HANDLE
new PlayerSeq[MAXPLAYERS+1];
new Handle:g_forward = INVALID_HANDLE;

// 玩家数据中心
new g_nIndex[MAXPLAYERS+1] = {0x00};
new g_nMoney[MAXPLAYERS+1] = {0x00};
new g_nExp[MAXPLAYERS+1] = {0x00};

new String:g_szSteam_id[MAXPLAYERS+1][33];
new String:g_szNamech[MAXPLAYERS+1][33];
new String:g_szRegdate[MAXPLAYERS+1][33];
new String:g_szRegip[MAXPLAYERS+1][33];
new String:g_szLastlogin[MAXPLAYERS+1][33];
new String:g_szLastip[MAXPLAYERS+1][33];

new String:g_szCommunity[MAXPLAYERS+1][64];
new String:g_szProfileState[MAXPLAYERS+1][64];
new String:g_szPersonNaName[MAXPLAYERS+1][64];
new String:g_szLastLogOff[MAXPLAYERS+1][64];
new String:g_szProfileUrl[MAXPLAYERS+1][64];
new String:g_szAvatar[MAXPLAYERS+1][64];
new String:g_szAvatarMid[MAXPLAYERS+1][64];
new String:g_szAvatarBig[MAXPLAYERS+1][64];

new String:g_szPersonState[MAXPLAYERS+1][64];
new String:g_szRealName[MAXPLAYERS+1][64];
new String:g_szPrimaryClanID[MAXPLAYERS+1][64];
new String:g_szTimeCreated[MAXPLAYERS+1][64];
new g_nTimeStamp[MAXPLAYERS+1] = {0x00};
new g_nXP[MAXPLAYERS+1] = {0x00};

public Plugin:myinfo =
{
	name = "CS:GO Login System",
	author = "Koma",
	description = "CSPub Login System.",
	version = "1.01",
	url = "http://www.cs-pub.com"
}

public OnPluginStart()
{
	RequestDatabaseConnection();
	
	g_forward = CreateGlobalForward( "client_login", ET_Ignore, Param_Cell, Param_Cell, Param_Cell ); 
	if(g_forward == INVALID_HANDLE)
	{
#if defined _DEBUG
		LogError("[CSPub] CreateGlobalForward = INVALID_HANDLE");
#endif
		return;
	}
	
	CreateNative("mt_get_user_index", Native_mt_get_user_index);
}

// 获取玩家数字编号
public Native_mt_get_user_index(Handle:plugin, numParams)
{
	if (numParams != 1)
	{
		PrintToServer ("mt_get_user_index() - incorrect param num");
		return 0;
	}
	
	new idx = GetNativeCell(1)
	if(idx < (MAXPLAYERS+1))
		return g_nIndex[idx]
	
	return 0
}

// 回调转发函数 —— 玩家登录时触发
public ForwardLogin(client, uid, exp)
{
	decl Action:result;
	
	/* Start function call */
	Call_StartForward(g_forward)
 
	/* Push parameters one at a time */
	Call_PushCell(client)
	Call_PushCell(uid)
	Call_PushCell(exp)

	/* Finish the call, get the result */
	Call_Finish(_:result);
	return result
}

public OnMapStart()
{
	RequestDatabaseConnection();
}

public bool InitSQLTable()
{
	if(hDatabase == INVALID_HANDLE)
		return 0;
		
	return 1;
}

public ClearnData(client)
{
	g_nIndex[client] = 0;
	g_nMoney[client] = 0;

	g_szSteam_id[client][0] 	= '\0';
	g_szNamech[client][0] 		= '\0';
	g_szRegdate[client][0] 		= '\0';
	g_szRegip[client][0] 		= '\0';
	g_szLastlogin[client][0] 	= '\0';
	g_szLastip[client][0] 		= '\0';
	
	g_nIndex[client] = 0;
	g_nMoney[client] = 0;
	g_nExp[client] = 0;

	g_szSteam_id[client][0] = '\0';
	g_szNamech[client][0] = '\0';
	g_szRegdate[client][0] = '\0';
	g_szRegip[client][0] = '\0';
	g_szLastlogin[client][0] = '\0';
	g_szLastip[client][0] = '\0';

	g_szCommunity[client][0] = '\0';
	g_szProfileState[client][0] = '\0';
	g_szPersonNaName[client][0] = '\0';
	g_szLastLogOff[client][0] = '\0';
	g_szProfileUrl[client][0] = '\0';
	g_szAvatar[client][0] = '\0';
	g_szAvatarMid[client][0] = '\0';
	g_szAvatarBig[client][0] = '\0';

	g_szPersonState[client][0] = '\0';
	g_szRealName[client][0] = '\0';
	g_szPrimaryClanID[client][0] = '\0';
	g_szTimeCreated[client][0] = '\0';
	g_nTimeStamp[client] = 0;
	g_nXP[client] = 0;
}

public KickPlayer(client)
{
	ServerCommand("sm_kick #%i", GetClientUserId(client));
}

public bool:OnClientConnect(client, String:rejectmsg[], maxlen)
{
	ClearnData(client);
	return true;
}

public OnClientDisconnect(client)
{
	ClearnData(client);
}

public OnMapEnd()
{
	if (hDatabase != INVALID_HANDLE)
	{
		CloseHandle(hDatabase);
		hDatabase = INVALID_HANDLE;
	}
}

public OnClientPutInServer(client)
{
	ClearnData(client);
	CheckUser(hDatabase,client);
}

public OnDatabaseConnect(Handle:owner, Handle:hndl, const String:error[], any:data)
{
#if defined _DEBUG
	PrintToServer("OnDatabaseConnect(%x,%x,%d) err:%s", owner, hndl, data, error);
#endif

	hDatabase = hndl;
	
	/**
	 * See if the connection is valid.  If not, don't un-mark the caches
	 * as needing rebuilding, in case the next connection request works.
	 */
	if (hDatabase == INVALID_HANDLE)
	{
		LogError("Failed to connect to database: %s", error);
		return;
	}
}

RequestDatabaseConnection()
{
	//SQL_TConnect(OnDatabaseConnect, "csgo");
	SQL_TConnect(OnDatabaseConnect);
}

CheckUser(Handle:db, client)
{
	decl String:name[65];
	decl String:safe_name[140];
	decl String:steamid[32];
	decl String:steamidalt[32];
	decl String:ipaddr[24];
	
	
	GetClientName(client, name, sizeof(name));
	GetClientIP(client, ipaddr, sizeof(ipaddr));
	
	steamid[0] = '\0';
	if (GetClientAuthString(client, steamid, sizeof(steamid)))
	{
		// 如果是盗版玩家则不允许登录
		if (StrEqual(steamid, "STEAM_ID_LAN"))
		{
			ClearnData(client);
			return 0;
		}
		
		if (StrEqual(steamid, "BOT"))
		{
			ClearnData(client);
			return 0;
		}
	}
	
	if (!GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid)))
		return 0;

	/**
	 * Construct the query using the information the user gave us.
	 */
	decl String:query[512];
	new len = 0;
	
	len = Format(query[len], sizeof(query)-len, "SELECT * FROM %s where steamid = '%s' ",TABLE_LOGIN,steamid);

#if defined _DEBUG
	PrintToServer("SQL: %s", query);
#endif
	
	new Handle:pk;
	pk = CreateDataPack();
	WritePackCell(pk, client);
	WritePackCell(pk, PlayerSeq[client]);
	WritePackString(pk, query);
	
	if(db == INVALID_HANDLE)
		RequestDatabaseConnection();
	
	SQL_TQuery(db, OnReceiveUserLogin, query, pk, DBPrio_High);
	return 0;
}

public OnReceiveUserLogin(Handle:owner, Handle:hndl, const String:error[], any:data)
{
#if defined _DEBUG
	PrintToServer("OnReceiveUserLogin called.")
#endif

	new Handle:pk = Handle:data;
	ResetPack(pk);
	
	new client = ReadPackCell(pk);
	
	/**
	 * Check if this is the latest result request.
	 */
	new sequence = ReadPackCell(pk);
	if (PlayerSeq[client] != sequence)
	{
		/* Discard everything, since we're out of sequence. */
		CloseHandle(pk);
		return;
	}
	
	/**
	 * If we need to use the results, make sure they succeeded.
	 */
	if (hndl == INVALID_HANDLE)
	{
	#if defined _DEBUG
		PrintToServer("GetClientOfUserId INVALID_HANDLE");
	#endif
		LogError("SQL error receiving user: %s", error);
		CloseHandle(pk);
		return;
	}
	
	new num_accounts = SQL_GetRowCount(hndl);
	if (num_accounts == 0)
	{
	#if defined _DEBUG
		PrintToServer("RegisterUser");
	#endif
		//CloseHandle(pk);
		RegisterUser(hDatabase,client,pk);
		return;
	}

	/*
	* Cache user info -- [0] = db id, [1] = cache id, [2] = groups
	*/
	while (SQL_FetchRow(hndl))
	{
		g_nIndex[client] = SQL_FetchInt(hndl, 0);
		SQL_FetchString(hndl, 1, g_szNamech[client], 	33);
		SQL_FetchString(hndl, 2, g_szRegdate[client], 	33);
		SQL_FetchString(hndl, 3, g_szRegip[client], 	33);
		SQL_FetchString(hndl, 4, g_szLastlogin[client], 33);
		SQL_FetchString(hndl, 5, g_szLastip[client], 	33);
		SQL_FetchString(hndl, 6, g_szSteam_id[client], 	33);
		SQL_FetchString(hndl, 7, g_szCommunity[client], 	64);
		SQL_FetchString(hndl, 8, g_szProfileState[client], 	64);
		SQL_FetchString(hndl, 9, g_szPersonNaName[client], 	64);
		SQL_FetchString(hndl, 10, g_szLastLogOff[client], 	64);
		SQL_FetchString(hndl, 11, g_szProfileUrl[client], 	64);
		SQL_FetchString(hndl, 12, g_szAvatar[client], 	64);
		SQL_FetchString(hndl, 13, g_szAvatarMid[client], 	64);
		SQL_FetchString(hndl, 14, g_szAvatarBig[client], 	64);
		SQL_FetchString(hndl, 15, g_szPersonState[client], 	64);
		SQL_FetchString(hndl, 16, g_szRealName[client], 	64);
		SQL_FetchString(hndl, 17, g_szPrimaryClanID[client], 	64);
		SQL_FetchString(hndl, 18, g_szTimeCreated[client], 	64);
		g_nTimeStamp[client]  	= SQL_FetchInt(hndl, 19);
		g_nXP[client]  			= SQL_FetchInt(hndl, 20);
		g_nMoney[client]		= SQL_FetchInt(hndl, 21);
	}
	
	ForwardLogin(client, g_nIndex[client], g_nXP[client]);
	
#if defined _DEBUG
	PrintToServer("[CSPub] Index=%d, SteamID=%s, %d, %s,%s,%s, %s,%s,%d)", 	\
		g_nIndex[client],g_szSteam_id[client],g_nMoney[client],			\
		g_szNamech[client],g_szRegdate[client],g_szRegip[client],		\
		g_szLastlogin[client],g_szLastip[client],g_nExp[client]);
#endif

	LoadUserFlags(hDatabase,client,pk);
	//CloseHandle(pk);
}

/*
	注册帐号
*/
public RegisterUser(Handle:db, client, Handle:pk)
{
	decl String:name[65];
	decl String:safe_name[140];
	decl String:steamid[32];
	decl String:steamidalt[32];
	decl String:ipaddr[24];
	decl String:time[32];
	decl String:utfquery[32];
	new Handle:TimeTmp = GetTime();
	FormatTime(time, sizeof(time), "%Y-%m-%d", TimeTmp);
	PrintToChat(client, "当前时间：%s", time);
	
	GetClientName(client, name, sizeof(name));
	GetClientIP(client, ipaddr, sizeof(ipaddr));
	
	steamid[0] = '\0';
	if (GetClientAuthString(client, steamid, sizeof(steamid)))
	{
		// 如果是盗版玩家则不允许登录
		if (StrEqual(steamid, "STEAM_ID_LAN"))
		{
			ClearnData(client);
			return 0;
		}
		
		if (StrEqual(steamid, "BOT"))
		{
			ClearnData(client);
			return 0;
		}
	}
	
	if (!GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid)))
		return 0;

	/**
	 * Construct the query using the information the user gave us.
	 */
	decl String:query[512];
	new len = 0;
	
	len = Format(query[len], sizeof(query)-len, "INSERT INTO %s (steamid,namech,regdate,regip) VALUES 	\
		('%s','%s','%s','%s')",TABLE_LOGIN,steamid,name,time,ipaddr);
	
#if defined _DEBUG
	PrintToServer("SQL: %s", query);
#endif

	/*new Handle:pk;
	pk = CreateDataPack();
	WritePackCell(pk, client);
	WritePackCell(pk, PlayerSeq[client]);
	WritePackString(pk, query);*/
	
	if(db == INVALID_HANDLE)
		RequestDatabaseConnection();

	Format(utfquery, sizeof(utfquery), "SET NAMES 'utf8';");
	if (SQL_FastQuery(db, utfquery, sizeof(utfquery)))
	{
		LogMessage("[AdsQL] - SET NAMES 'utf8' query succeeded.");
	}
	else
	{
		LogMessage("[AdsQL] - SET NAMES 'utf8' query FAILED!");
	}
	
	SQL_TQuery(db, OnReceiveUserRegister, query, pk, DBPrio_High);
	return 0;
}

public OnReceiveUserRegister(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new Handle:pkRet = Handle:data;
	ResetPack(pkRet);
	
	new client = ReadPackCell(pkRet);
	
	/**
	 * Check if this is the latest result request.
	 */
	new sequence = ReadPackCell(pkRet);
	if (PlayerSeq[client] != sequence)
	{
		/* Discard everything, since we're out of sequence. */
		CloseHandle(pkRet);
		return;
	}
	
	/**
	 * If we need to use the results, make sure they succeeded.
	 */
	if (hndl == INVALID_HANDLE)
	{
		LogError("SQL error receiving user: %s", error);
		return;
	}
	
	// 如果首次注册将重新登录以便获取index
	CheckUser(hDatabase, client);
	CloseHandle(pkRet);
}

/*
	获取帐号权限道具
*/
public LoadUserFlags(Handle:db, client, Handle:pk)
{
	decl String:name[65];
	decl String:safe_name[140];
	decl String:steamid[32];
	decl String:steamidalt[32];
	decl String:ipaddr[24];
	decl String:time[32];
	decl String:utfquery[32];
	new Handle:TimeTmp = GetTime();
	FormatTime(time, sizeof(time), "%Y-%m-%d", TimeTmp);
	PrintToChatAll( "当前时间：%s", time);
	
	GetClientName(client, name, sizeof(name));
	GetClientIP(client, ipaddr, sizeof(ipaddr));
	
	steamid[0] = '\0';
	if (GetClientAuthString(client, steamid, sizeof(steamid)))
	{
		// 如果是盗版玩家则不允许登录
		if (StrEqual(steamid, "STEAM_ID_LAN"))
		{
			ClearnData(client);
			CloseHandle(pk);
			return 0;
		}
		
		if (StrEqual(steamid, "BOT"))
		{
			ClearnData(client);
			CloseHandle(pk);
			return 0;
		}
	}
	
	if (!GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid)))
	{
		ClearnData(client);
		CloseHandle(pk);
		return 0;
	}
	
	/**
	 * Construct the query using the information the user gave us.
	 */
	decl String:query[512];
	new len = 0;
	new TimeNow = GetTime();
	
	// 根据当前时间戳判断VIP是否过期
	len = Format(query[len], sizeof(query)-len, "SELECT * FROM %s where steamid = '%s' and expdate >= %d",TABLE_FLAG, steamid, TimeTmp);
	
#if defined _DEBUG
	PrintToServer("SQL: %s", query);
#endif

	if(db == INVALID_HANDLE)
		RequestDatabaseConnection();

	Format(utfquery, sizeof(utfquery), "SET NAMES 'utf8';");
	if (SQL_FastQuery(db, utfquery, sizeof(utfquery)))
	{
		LogMessage("[AdsQL] - SET NAMES 'utf8' query succeeded.");
	}
	else
	{
		LogMessage("[AdsQL] - SET NAMES 'utf8' query FAILED!");
	}
	
	SQL_TQuery(db, OnReceiveUserFlag, query, pk, DBPrio_High);
	return 0;
}

public OnReceiveUserFlag(Handle:owner, Handle:hndl, const String:error[], any:data)
{
#if defined _DEBUG
	PrintToServer("OnReceiveUserFlag called.")
#endif

	new String:flagsTotal[33];
	new String:flagsTemp[33];
	new String:szName[33];
	
	new Handle:pk = Handle:data;
	ResetPack(pk);
	
	new client = ReadPackCell(pk);
	
	flagsTotal[0] = '\0';
	flagsTemp[0]  = '\0';
	GetClientName(client, szName, sizeof(szName));
	
	/**
	 * Check if this is the latest result request.
	 */
	new sequence = ReadPackCell(pk);
	if (PlayerSeq[client] != sequence)
	{
		/* Discard everything, since we're out of sequence. */
		CloseHandle(pk);
		return;
	}
	
	/**
	 * If we need to use the results, make sure they succeeded.
	 */
	if (hndl == INVALID_HANDLE)
	{
		LogError("SQL error receiving user: %s", error);
		CloseHandle(pk);
		return;
	}
	
	new num_accounts = SQL_GetRowCount(hndl);
	if (num_accounts == 0)
	{
	#if defined _DEBUG
		PrintToServer("OnReceiveUserFlag");
	#endif
		CloseHandle(pk);
		return;
	}

	/*
	* Cache user info -- [0] = db id, [1] = cache id, [2] = groups
	*/
	while (SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 2, flagsTemp, 33);
		if(strlen(flagsTemp))
			StrCat(flagsTotal,33,flagsTemp);
	}

	if(strlen(flagsTotal) == 0)
	{
		PrintToChat(client,"欢迎【普通会员】%s 回来！",szName);
		CloseHandle(pk);
		return;
	}
	
	new nCount = 0;
	new nFlags = 0;
	
	nCount = strlen(flagsTotal);
	nFlags = ReadFlagString(flagsTotal,nCount);
	if(nFlags)
	{
		SetUserFlagBits(client,nFlags);
	}

#if defined _DEBUG
	if(IsClientInGame(client))
	{
		PrintToChat(client,"%s 的权限有: %s   %d", szName, flagsTotal, nFlags);
	}
	
	PrintToServer("OnReceiveUserFlag called end flags:%s   %d",flagsTotal, nFlags)
#endif
	
	CloseHandle(pk);
}
