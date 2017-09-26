#pragma semicolon 1

#define PLUGIN_VERSION "1.2"

#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <emitsoundany>
#include <warden>

ConVar cvSndWarden;
char sSndWarden[256];

ConVar cvSndWardenDied;
char sSndWardenDied[256];

public Plugin myinfo = 
{
	name = "warden Sounds",
	author = ".#Zipcore",
	description = "www.theedgeclan.com",
	version = PLUGIN_VERSION,
	url = "www.theeddgeclan.net"
};

public void OnPluginStart()
{
	CreateConVar("warden_sounds_version", PLUGIN_VERSION, "Warden Sounds version", FCVAR_DONTRECORD|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	cvSndWarden = CreateConVar("warden_sounds_path", "warden/enter.mp3", "Path to the sound which should be played for a new warden.");
	GetConVarString(cvSndWarden, sSndWarden, sizeof(sSndWarden));
	HookConVarChange(cvSndWarden, OnSettingChanged);
	
	cvSndWardenDied = CreateConVar("warden_sounds_path2", "warden/leave.mp3", "Path to the sound which should be played when there is no warden anymore.");
	GetConVarString(cvSndWardenDied, sSndWardenDied, sizeof(sSndWardenDied));
	HookConVarChange(cvSndWardenDied, OnSettingChanged);
	
	AutoExecConfig(true, "warden-sounds");
}

public void OnMapStart()
{
	PrecacheSoundAnyDownload(sSndWarden);
	PrecacheSoundAnyDownload(sSndWardenDied);
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == cvSndWarden)
	{
		strcopy(sSndWarden, sizeof(sSndWarden), newValue);
		PrecacheSoundAnyDownload(sSndWarden);
	}
	else if(convar == cvSndWardenDied)
	{
		strcopy(sSndWardenDied, sizeof(sSndWardenDied), newValue);
		PrecacheSoundAnyDownload(sSndWardenDied);
	}
}

public Action playerDeath(Handle event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(warden_iswarden(client))
		EmitSoundToAllAny(sSndWardenDied);
}

public void warden_OnWardenCreated(int client)
{
	EmitSoundToAllAny(sSndWarden);
}

public void warden_OnWardenRemoved(int client)
{
	EmitSoundToAllAny(sSndWardenDied);
}

void PrecacheSoundAnyDownload(char[] sSound)
{
	PrecacheSoundAny(sSound);
	
	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "sound/%s", sSound);
	AddFileToDownloadsTable(sBuffer);
}