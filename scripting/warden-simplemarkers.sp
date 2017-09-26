#pragma semicolon 1

#define PLUGIN_VERSION "1.2"

#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <warden>

int g_MarkerColor[] = {25,255,25,255};

ConVar g_cvEnabled;
bool g_bEnabled;

public Plugin myinfo = 
{
	name = "Warden: Simple Markers",
	author = ".#Zipcore",
	description = "www.theedgeclan.com",
	version = PLUGIN_VERSION,
	url = "www.thedgeclan.com"
};

float g_fMakerPos[3];

int g_iBeamSprite = -1;
int g_iHaloSprite = -1;

public void OnPluginStart()
{
	CreateConVar("warden_simplemarkers_version", PLUGIN_VERSION, "Warden Simple Markers version", FCVAR_DONTRECORD|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	g_cvEnabled = CreateConVar("warden_simplemarkers_enable", "1", "Set 0 to disable this plugin.");
	g_bEnabled = GetConVarBool(g_cvEnabled);
	HookConVarChange(g_cvEnabled, Action_OnSettingsChange);
	
	AddCommandListener(Command_LAW, "+lookatweapon");
	
	CreateTimer(1.0, Timer_DrawMakers, _, TIMER_REPEAT);
}

public void OnMapStart()
{
	ResetMarker();
	
	if (GetEngineVersion() == Engine_CSS)
	{
		g_iBeamSprite = PrecacheModel("materials/sprites/laser.vmt");
		g_iHaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
	}
	else if (GetEngineVersion() == Engine_CSGO)
	{
		g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
		g_iHaloSprite = PrecacheModel("materials/sprites/glow01.vmt");
	}
}

public void Action_OnSettingsChange(Handle cvar, const char[] oldvalue, const char[] newvalue)
{
	if (cvar == g_cvEnabled)
	{
		g_bEnabled = view_as<bool>(StringToInt(newvalue));
	}
}

public Action Command_LAW(int client, const char[] command, int argc)
{
	if(!g_bEnabled)
		return Plugin_Continue;
	
	if(!client || !IsClientInGame(client) || !IsPlayerAlive(client))
		return Plugin_Continue;
		
	if(!warden_iswarden(client))
		return Plugin_Continue;
	
	GetClientAimTargetPos(client, g_fMakerPos);
	g_fMakerPos[2] += 5.0;
	
	CPrintToChat(client, "{green}[{darkred}Marker{green}] {lime}Marker placed.");
		
	return Plugin_Continue;
}

public void warden_OnWardenCreated(int client)
{
	ResetMarker();
}

public void warden_OnWardenRemoved(int client)
{
	ResetMarker();
}

int GetClientAimTargetPos(int client, float pos[3]) 
{
	if (!client) 
		return -1;
	
	float vAngles[3]; float vOrigin[3];
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceFilterAllEntities, client);
	
	TR_GetEndPosition(pos, trace);
	pos[2] += 5.0;
	
	int entity = TR_GetEntityIndex(trace);
	
	CloseHandle(trace);
	
	return entity;
}

void ResetMarker()
{
	for(int i = 0; i < 3; i++)
		g_fMakerPos[i] = 0.0;
}

public bool TraceFilterAllEntities(int entity, int contentsMask, any client)
{
	if (entity == client)
		return false;
	if (entity > MaxClients)
		return false;
	if(!IsClientInGame(entity))
		return false;
	if(!IsPlayerAlive(entity))
		return false;
	
	return true;
}

public Action Timer_DrawMakers(Handle timer, any data)
{
	Draw_Markers();
	return Plugin_Continue;
}

void Draw_Markers()
{
	if(!g_cvEnabled)
		return;
	
	if (g_fMakerPos[0] == 0.0)
		return;
	
	if(!warden_exist())
		return;
		
	// Show the ring
	
	TE_SetupBeamRingPoint(g_fMakerPos, 155.0, 155.0+0.1, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 6.0, 0.0, g_MarkerColor, 2, 0);
	TE_SendToAll();
	
	// Show the arrow
	
	float fStart[3];
	AddVectors(fStart, g_fMakerPos, fStart);
	fStart[2] += 0.0;
	
	float fEnd[3];
	AddVectors(fEnd, fStart, fEnd);
	fEnd[2] += 200.0;
	
	TE_SetupBeamPoints(fStart, fEnd, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 4.0, 16.0, 1, 0.0, g_MarkerColor, 5);
	TE_SendToAll();
}