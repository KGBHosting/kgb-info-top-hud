#include <amxmodx>
#include <amxmisc>

#pragma semicolon 1

#define PLUGIN_NAME "KGB Info Top HUD"
#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_AUTHOR "KGB Hosting"

#define CONFIG_FILE_NAME "kgb_info_top_hud.cfg"
#define CHAT_BUFFER 192
#define SMALL_BUFFER 64
#define IP_BUFFER 32
#define LANGUAGE_SERBIAN 0
#define LANGUAGE_ENGLISH 1

enum
{
	Cvar_Enabled,
	Cvar_Language,
	Cvar_Prefix,
	Cvar_ShowChat,
	Cvar_ShowHud,
	Cvar_HudText,
	Cvar_HudRed,
	Cvar_HudGreen,
	Cvar_HudBlue,
	Cvar_HudX,
	Cvar_HudY,
	Cvar_HudEffect,
	Cvar_HudFxTime,
	Cvar_HudHoldTime,
	Cvar_Count
};

new const g_CvarNames[Cvar_Count][] =
{
	"kgb_ith_enabled",
	"kgb_ith_language",
	"kgb_ith_prefix",
	"kgb_ith_show_chat",
	"kgb_ith_show_hud",
	"kgb_ith_hud_text",
	"kgb_ith_hud_red",
	"kgb_ith_hud_green",
	"kgb_ith_hud_blue",
	"kgb_ith_hud_x",
	"kgb_ith_hud_y",
	"kgb_ith_hud_effect",
	"kgb_ith_hud_fxtime",
	"kgb_ith_hud_holdtime"
};

new const g_CvarDefaults[Cvar_Count][] =
{
	"1",
	"sr",
	"KGB",
	"1",
	"1",
	"",
	"255",
	"85",
	"0",
	"-1.0",
	"0.0",
	"2",
	"6.0",
	"180.0"
};

new g_CvarPointer[Cvar_Count];
new g_ConfigPath[128];
new g_MaxPlayers;
new g_RoundNumber;
new g_SayText;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_cvar("kgb_info_top_hud", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY);
	register_cvar("infotop", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY);

	for (new i = 0; i < Cvar_Count; i++)
	{
		g_CvarPointer[i] = register_cvar(g_CvarNames[i], g_CvarDefaults[i]);
	}

	register_event("HLTV", "Event_NewRound", "a", "1=0", "2=0");
	register_event("TextMsg", "Event_RoundRestart", "a", "2=#Game_will_restart_in");
	register_event("TextMsg", "Event_RoundRestart", "a", "2=#Game_Commencing");
	register_srvcmd("amx_prefix", "Command_SetPrefix");

	g_MaxPlayers = get_maxplayers();
	g_SayText = get_user_msgid("SayText");
}

public plugin_cfg()
{
	BuildConfigPath();
	EnsureDefaultConfig();

	server_cmd("exec ^"%s^"", g_ConfigPath);
}

public Event_RoundRestart()
{
	g_RoundNumber = 0;
}

public Event_NewRound()
{
	if (!get_pcvar_num(g_CvarPointer[Cvar_Enabled]))
	{
		return;
	}

	g_RoundNumber++;

	ShowServerHudInfo();
	SendRoundChatInfo();
}

public Command_SetPrefix()
{
	new prefix[SMALL_BUFFER];
	read_argv(1, prefix, charsmax(prefix));
	trim(prefix);

	if (!prefix[0])
	{
		server_print("Usage: amx_prefix <prefix>");
		return PLUGIN_HANDLED;
	}

	set_pcvar_string(g_CvarPointer[Cvar_Prefix], prefix);
	server_print("%s prefix changed to: %s", PLUGIN_NAME, prefix);

	return PLUGIN_HANDLED;
}

stock BuildConfigPath()
{
	new configsDir[96];
	get_configsdir(configsDir, charsmax(configsDir));
	formatex(g_ConfigPath, charsmax(g_ConfigPath), "%s/%s", configsDir, CONFIG_FILE_NAME);
}

stock EnsureDefaultConfig()
{
	if (file_exists(g_ConfigPath))
	{
		return;
	}

	write_file(g_ConfigPath, "// KGB Info Top HUD - Podesavanja");
	write_file(g_ConfigPath, "kgb_ith_enabled ^"1^"");
	write_file(g_ConfigPath, "kgb_ith_language ^"sr^"   // sr/serbian ili en/english");
	write_file(g_ConfigPath, "kgb_ith_prefix ^"KGB^"");
	write_file(g_ConfigPath, "kgb_ith_show_chat ^"1^"");
	write_file(g_ConfigPath, "kgb_ith_show_hud ^"1^"");
	write_file(g_ConfigPath, "kgb_ith_hud_text ^"^"   // Prazno koristi tekst iz izabranog jezika. {ip} ubacuje server IP.");
	write_file(g_ConfigPath, "kgb_ith_hud_red ^"255^"");
	write_file(g_ConfigPath, "kgb_ith_hud_green ^"85^"");
	write_file(g_ConfigPath, "kgb_ith_hud_blue ^"0^"");
	write_file(g_ConfigPath, "kgb_ith_hud_x ^"-1.0^"");
	write_file(g_ConfigPath, "kgb_ith_hud_y ^"0.0^"");
	write_file(g_ConfigPath, "kgb_ith_hud_effect ^"2^"");
	write_file(g_ConfigPath, "kgb_ith_hud_fxtime ^"6.0^"");
	write_file(g_ConfigPath, "kgb_ith_hud_holdtime ^"180.0^"");
	write_file(g_ConfigPath, "");
	write_file(g_ConfigPath, "// Legacy compatibility: amx_prefix <prefix> updates kgb_ith_prefix until the next config reload.");
}

stock ShowServerHudInfo()
{
	if (!get_pcvar_num(g_CvarPointer[Cvar_ShowHud]))
	{
		return;
	}

	new serverIp[IP_BUFFER];
	new message[CHAT_BUFFER];

	get_user_ip(0, serverIp, charsmax(serverIp));
	GetHudText(message, charsmax(message), serverIp);

	if (!message[0])
	{
		return;
	}

	set_hudmessage(
		ClampByte(get_pcvar_num(g_CvarPointer[Cvar_HudRed])),
		ClampByte(get_pcvar_num(g_CvarPointer[Cvar_HudGreen])),
		ClampByte(get_pcvar_num(g_CvarPointer[Cvar_HudBlue])),
		get_pcvar_float(g_CvarPointer[Cvar_HudX]),
		get_pcvar_float(g_CvarPointer[Cvar_HudY]),
		get_pcvar_num(g_CvarPointer[Cvar_HudEffect]),
		get_pcvar_float(g_CvarPointer[Cvar_HudFxTime]),
		get_pcvar_float(g_CvarPointer[Cvar_HudHoldTime])
	);

	show_hudmessage(0, "%s", message);
}

stock SendRoundChatInfo()
{
	if (!get_pcvar_num(g_CvarPointer[Cvar_ShowChat]))
	{
		return;
	}

	new prefix[SMALL_BUFFER];
	new roundLabel[SMALL_BUFFER];
	new mapLabel[SMALL_BUFFER];
	new playersLabel[SMALL_BUFFER];
	new currentMap[32];
	new nextMap[32];
	new players[32];
	new playerCount;
	new maxRounds = get_cvar_num("mp_maxrounds");
	new language = GetConfiguredLanguage();

	get_pcvar_string(g_CvarPointer[Cvar_Prefix], prefix, charsmax(prefix));
	trim(prefix);

	if (!prefix[0])
	{
		copy(prefix, charsmax(prefix), "KGB");
	}

	get_mapname(currentMap, charsmax(currentMap));
	get_cvar_string("amx_nextmap", nextMap, charsmax(nextMap));
	get_players(players, playerCount);
	GetChatLabels(
		language,
		roundLabel,
		charsmax(roundLabel),
		mapLabel,
		charsmax(mapLabel),
		playersLabel,
		charsmax(playersLabel)
	);

	new message[CHAT_BUFFER];
	format(
		message,
		charsmax(message),
		"^x04[%s]^x01 %s: ^x03%d^x01/^x03%d ^x01| %s: ^x03%s^x01/^x03%s ^x01| %s: ^x03%d^x01/^x03%d",
		prefix,
		roundLabel,
		g_RoundNumber,
		maxRounds,
		mapLabel,
		currentMap,
		nextMap,
		playersLabel,
		playerCount,
		g_MaxPlayers
	);

	BroadcastSayText(message);
}

stock GetHudText(output[], outputLen, const serverIp[])
{
	get_pcvar_string(g_CvarPointer[Cvar_HudText], output, outputLen);
	trim(output);

	if (!output[0])
	{
		GetDefaultHudText(output, outputLen, GetConfiguredLanguage());
	}

	replace_all(output, outputLen, "{ip}", serverIp);
}

stock GetConfiguredLanguage()
{
	new language[SMALL_BUFFER];
	get_pcvar_string(g_CvarPointer[Cvar_Language], language, charsmax(language));
	trim(language);

	if (equali(language, "en") || equali(language, "eng") || equali(language, "english"))
	{
		return LANGUAGE_ENGLISH;
	}

	return LANGUAGE_SERBIAN;
}

stock GetDefaultHudText(output[], outputLen, language)
{
	switch (language)
	{
		case LANGUAGE_ENGLISH:
		{
			copy(output, outputLen, "Add IP: {ip}");
		}
		default:
		{
			copy(output, outputLen, "Dodajte IP: {ip}");
		}
	}
}

stock GetChatLabels(language, roundLabel[], roundLen, mapLabel[], mapLen, playersLabel[], playersLen)
{
	switch (language)
	{
		case LANGUAGE_ENGLISH:
		{
			copy(roundLabel, roundLen, "Round");
			copy(mapLabel, mapLen, "Map");
			copy(playersLabel, playersLen, "Players");
		}
		default:
		{
			copy(roundLabel, roundLen, "Runda");
			copy(mapLabel, mapLen, "Mapa");
			copy(playersLabel, playersLen, "Igraca");
		}
	}
}

stock BroadcastSayText(const message[])
{
	new players[32], playerCount;
	get_players(players, playerCount, "ch");

	for (new i = 0; i < playerCount; i++)
	{
		SendSayText(players[i], 0, message);
	}
}

stock SendSayText(recipient, sender, const message[])
{
	if (!recipient || !is_user_connected(recipient) || is_user_bot(recipient))
	{
		return;
	}

	message_begin(MSG_ONE, g_SayText, _, recipient);
	write_byte(sender > 0 ? sender : recipient);
	write_string(message);
	message_end();
}

stock ClampByte(value)
{
	if (value < 0)
	{
		return 0;
	}

	if (value > 255)
	{
		return 255;
	}

	return value;
}
