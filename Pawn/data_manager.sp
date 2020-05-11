/*
	排名中转插件
	<py + redis做为排名数据库统计>
	此插件只与data_manager.py通讯
	by Koma 2015.06.16
	http://www.cs-pub.com
*/
#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>
#include <sdkhooks>

#include "Public/MD5.sp"
#include "Public/socket.inc"

// 是否调试
#define _DEBUG

// data_manager.py的ip/端口
#define HOST 			"127.0.0.1"
#define PORT 			7777

#define is_player(%1) 	IsClientInGame(%1)
#define MAX_PACKET_SIZE 1400
#define OFFSET_DATA 	14

#define char_to_byte(%1) 				((%1<0)?(%1+256):%1)
#define byte_array_to_int(%1,%2,%3,%4) 	(char_to_byte(%1)+(char_to_byte(%2)<<8)+(char_to_byte(%3)<<16)+(char_to_byte(%4)<<24))

new Handle:g_socket = INVALID_HANDLE;
new String:g_field_qid[65536]
new g_current_qid
new String:g_md5_server_name[34]

new String:g_packet_push[MAX_PACKET_SIZE]
new String:g_packet[MAX_PACKET_SIZE]
new g_push_counter
new Float:g_time_update
new Handle:g_forward = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "CS:GO Data Manager",
	author = "Koma",
	description = "CSPub Data Manager.",
	version = "1.01",
	url = "http://www.cs-pub.com"
}

public OnPluginStart()
{
	new String:server_name[128];
	GetClientName(0, server_name, 128);
	MD5String(server_name,g_md5_server_name,34);
	
	g_packet_push[0] = 0x59;
	g_packet_push[1] = 0x40;
	//g_packet[2] = qtype
	g_packet_push[3] = g_md5_server_name[0];
	g_packet_push[4] = g_md5_server_name[1];
	g_packet_push[5] = g_md5_server_name[2];
	g_packet_push[6] = g_md5_server_name[3];

	g_packet[0] = 0x59;
	g_packet[1] = 0x40;
	//g_packet[2] = qtype
	g_packet[3] = g_md5_server_name[0];
	g_packet[4] = g_md5_server_name[1];
	g_packet[5] = g_md5_server_name[2];
	g_packet[6] = g_md5_server_name[3];

	CreateNative("dm_push_stats", Native_dm_push_stats);
	CreateNative("dm_get_stats", Native_dm_get_stats);
	RegPluginLibrary("data_manager");
	
	RegConsoleCmd("say", SayChatTest);
    RegConsoleCmd("say_team", SayChatTest);
	
	dm_init();
	
	g_forward = CreateGlobalForward( "receive_stats", ET_Ignore, Param_Cell, Param_Array ); 
	if(g_forward == INVALID_HANDLE)
	{
#if defined _DEBUG
		LogError("[CSPub] CreateGlobalForward = INVALID_HANDLE");
#endif
		return;
	}
	
#if defined _DEBUG
	LogError("[CSPub] CreateGlobalForward success.");
#endif
}

public Native_dm_push_stats(Handle:plugin, numParams)
{
	if (numParams != 4)
	{
		PrintToServer ("dm_push_stats() - incorrect param num");
		return 0;
	}
	
	push_stats(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3), GetNativeCell(4));
	return 1
}

public Native_dm_get_stats(Handle:plugin, numParams)
{
	if (numParams != 2)
	{
		PrintToServer ("dm_get_stats() - incorrect param num");
		return 0;
	}

	get_stats(GetNativeCell(1), GetNativeCell(2))
	return 1
}




public Action:SayChatTest(client, args)
{
	PrintToChatAll("SayChatTest");
	PrintToServer("SayChatTest");
	if(!client)
		return(Plugin_Continue);

	if(!IsClientInGame(client))
		return(Plugin_Handled);
	
	static String:data[16]
	new i = 0;
	for (; i < 500; i++)
	{
		IntToString(i, data, 15);
		new len = strlen(data);
		data[len] = 0;
		socket_send2(g_socket, data, len); // do not send the '/0'
	}
	
	PrintToChat(client, "i = %d", i);
	PrintToServer("SayChatTest");
	return(Plugin_Handled);
}

public dm_init()
{
	g_socket = SocketCreate(SOCKET_UDP, OnSocketError);
	if(g_socket == INVALID_HANDLE)
	{
#if defined _DEBUG
		LogError("[CSPub] dm_init g_socket = INVALID_HANDLE");
#endif
		return;
	}

#if defined _DEBUG
		LogError("[CSPub] dm_init g_socket success.");
#endif

	//SocketConnect(g_socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, HOST, PORT)
	SocketSetReceiveCallback(g_socket, OnChildSocketReceive);
	SocketSetDisconnectCallback(g_socket, OnChildSocketDisconnected);
	SocketSetErrorCallback(g_socket, OnChildSocketError);
}

public OnSocketError(Handle:socket, const errorType, const errorNum, any:hFile)
{
	LogError("socket error %d (errno %d)", errorType, errorNum);
	CloseHandle(hFile);
	CloseHandle(socket);
}

public OnChildSocketError(Handle:socket, const errorType, const errorNum, any:ary)
{
	// a socket error occured
	LogError("child socket error %d (errno %d)", errorType, errorNum);
	CloseHandle(socket);
}

public OnChildSocketReceive(Handle:socket, String:receiveData[], const dataSize, any:hFile)
{
	static 	frameid;
	static 	String:buffer[1024];
	new 	len = dataSize;

	if(len <= 0)
		return;
		
	frameid++;
	strcopy(buffer,1024,receiveData);
	
#if defined _DEBUG
	PrintToServer("get:%d:%d:%d:%s", frameid, strlen(buffer), len, buffer)
#endif
	if (len <= 0 || buffer[0] != 0x59 || buffer[1] != 0x40)
	{
		return
	}
#if defined _DEBUG
	PrintToServer("recv:%d:%d:%s", frameid, strlen(buffer), buffer)
#endif
		
	new qid;
	new String:data[13];
	
	qid = char_to_byte(buffer[3]) + (char_to_byte(buffer[4]) << 8)
	g_field_qid[qid] = 0
	switch (buffer[2])
	{
		case 0x10:
		{
			conv_data_array(buffer[10], data, 13);
			_get_stats(buffer[5], data); 			// buffer[5] = id
			PrintToServer("succ");
		}
		case 0x40:
		{
			PrintToServer("0x40 error");
		}
		case 0x70:
		{
			PrintToServer("0x70 not found");
		}
	}
}

public OnChildSocketDisconnected(Handle:socket, any:hFile) {
	// remote side disconnected

	CloseHandle(socket);
}

stock dm_create_head(String:packet[], id, qtype)
{
	static time_stamp;
	time_stamp = GetTime();
	if (++g_current_qid > 65535)
	{
		g_current_qid = 0
	}
	
	g_field_qid[g_current_qid] = 1
	//packet[0] = 0x59
	//packet[1] = 0x40
	packet[2] = qtype
	//packet[3] = g_md5_server_name[0]
	//packet[4] = g_md5_server_name[1]
	//packet[5] = g_md5_server_name[2]
	//packet[6] = g_md5_server_name[3]
	packet[7] = g_current_qid & 255
	packet[8] = g_current_qid >> 8
	packet[9] = id
	packet[10] = time_stamp & 255
	packet[11] = time_stamp >> 8 & 255
	packet[12] = time_stamp >> 16 & 255
	packet[13] = time_stamp >> 24 & 255
}

public OnPluginEnd()
{
	if (g_push_counter)
	{
		update_stats();
	}
	
	if(g_socket != INVALID_HANDLE)
	{
		CloseHandle(g_socket);
		g_socket = INVALID_HANDLE;
	}
}

public OnGameFrame()
{
	if (g_socket <= INVALID_HANDLE)
		return
	
	if (g_push_counter > 100 || GetGameTime() - g_time_update > 1.0 && g_push_counter)
	{
		update_stats()
	}

	if (SocketSetOption(g_socket, SocketReceiveTimeout, 1))
	{
		// 等待接收数据
	}
}

public get_stats(id, uid)
{
	dm_create_head(g_packet, id, 0x10)
	g_packet[OFFSET_DATA] = uid & 255
	g_packet[OFFSET_DATA + 1] = uid >> 8 & 255
	g_packet[OFFSET_DATA + 2] = uid >> 16 & 255
	g_packet[OFFSET_DATA + 3] = uid >> 24 & 255
#if defined _DEBUG
	PrintToServer("get_stats(%d)", uid)
#endif

	socket_send2(g_socket, g_packet, OFFSET_DATA + 4);
}

public conv_data_array(String:source[], String:dest[], len)
{
	for (new i; i < len; i++)
	{
		dest[i] = byte_array_to_int(source[4 * i], source[4 * i + 1], source[4 * i + 2], source[4 * i + 3])
	}
}

public update_stats()
{
	g_time_update = GetGameTime();
	dm_create_head(g_packet_push, g_push_counter, 0x20);
#if defined _DEBUG
	static counter;
	PrintToServer("pushes=%d packets=%d", g_packet_push[9], ++counter);
#endif
	socket_send2(g_socket, g_packet_push, OFFSET_DATA + g_push_counter * 10);
	g_push_counter = 0;
}

public _get_stats(id,  String:data[])
{
	return 0;
}


public push_stats(category, weapon_id, uid, increment)
{
	//server_print("%d %d %d %d", category, weapon_id, uid, increment)
	new base_offset = OFFSET_DATA + g_push_counter * 10
	if (base_offset >=  MAX_PACKET_SIZE - 10)
	{
		update_stats();
		base_offset = OFFSET_DATA;
	}
	g_packet_push[base_offset] = category;
	g_packet_push[base_offset + 1] = weapon_id + '@'; // 'A', 'B', 'C'...
	g_packet_push[base_offset + 2] = uid & 255;
	g_packet_push[base_offset + 3] = uid >> 8 & 255;
	g_packet_push[base_offset + 4] = uid >> 16 & 255;
	g_packet_push[base_offset + 5] = uid >> 24 & 255;
	g_packet_push[base_offset + 6] = increment & 255;
	g_packet_push[base_offset + 7] = increment >> 8 & 255;
	g_packet_push[base_offset + 8] = increment >> 16 & 255;
	g_packet_push[base_offset + 9] = increment >> 24 & 255;

	g_push_counter++;
}

public OnMapStart()
{
}

public socket_send2(Handle:hSocket, String:data[], length)
{
	return SocketSendTo(hSocket, data, length, HOST, PORT);
}