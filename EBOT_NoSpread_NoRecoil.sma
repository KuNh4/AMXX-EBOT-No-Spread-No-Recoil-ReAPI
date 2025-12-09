/*================================================================================
    
    Plugin: [E-BOT] No Spread & No Recoil (ReAPI)
    Version: 1.0
    Author: KuNh4

    - Removes recoil and spread for E-BOTs when moving and shooting;
    - No Spread: Bullets have no spread (visually in the client they do) but in server side they don't;
    - No Recoil: Removes weapon recoil;

    Note: This plugin requires ReAPI to work, and can be used on any BOTS.
    You can also use this code to make a NoSpread or/and NoRecoil extra item for players.
    
================================================================================*/

#include <amxmodx>
#include <reapi>


#define PLUGIN "[E-BOT] No Spread & No Recoil (ReAPI)"
#define VERSION "1.0"
#define AUTHOR "KuNh4"

new g_pCvarNoSpread
new g_pCvarNoRecoil

new g_iNoSpread
new g_iNoRecoil

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    g_pCvarNoSpread = register_cvar("ebot_aim_nospread", "1")
    g_pCvarNoRecoil = register_cvar("ebot_aim_norecoil", "1")

    bind_pcvar_num(g_pCvarNoSpread, g_iNoSpread)
    bind_pcvar_num(g_pCvarNoRecoil, g_iNoRecoil)

    hook_cvar_change(g_pCvarNoSpread, "OnCvarChange_NoSpread")
    hook_cvar_change(g_pCvarNoRecoil, "OnCvarChange_NoRecoil")

    RegisterHookChain(RG_CBasePlayerWeapon_KickBack, "OnWeaponKickBack", false)
    RegisterHookChain(RG_CBaseEntity_FireBullets3, "OnFireBullets3_Pre", false)
    
    register_srvcmd("ebot_norecoil_info", "ServerCmd_Info")
    register_srvcmd("ebot_nospread_info", "ServerCmd_Info")
    
    server_print("[E-BOT No Spread & No Recoil] has loaded successfully! [Type ebot_norecoil_info][ebot_nospread_info]")
}

public plugin_cfg()
{
    server_cmd("exec addons/amxmodx/configs/ebot_nospread_norecoil.cfg")
}


public ServerCmd_Info()
{
    server_print("======================================================")
    server_print(" %s v%s by %s", PLUGIN, VERSION, AUTHOR)
    server_print("======================================================")
    server_print(" [E-BOT] No Spread: %s", g_iNoSpread ? "ON" : "OFF")
    server_print(" [E-BOT] No Recoil: %s", g_iNoRecoil ? "ON" : "OFF")
    server_print("======================================================")
    
    return PLUGIN_HANDLED
}

public OnCvarChange_NoSpread(pcvar, const old_value[], const new_value[])
{
    server_print("[E-BOT No Spread & No Recoil] No Spread changed from %s to %s", old_value, new_value)
    server_print("[E-BOT No Spread & No Recoil] No Spread is now: %s", g_iNoSpread ? "ENABLED" : "DISABLED")
}

public OnCvarChange_NoRecoil(pcvar, const old_value[], const new_value[])
{
    server_print("[E-BOT No Spread & No Recoil] No Recoil changed from %s to %s", old_value, new_value)
    server_print("[E-BOT No Spread & No Recoil] No Recoil is now: %s", g_iNoRecoil ? "ENABLED" : "DISABLED")
}


// No-Recoil
public OnWeaponKickBack(const pWeapon, Float:up_base, Float:lateral_base, Float:up_modifier, Float:lateral_modifier, Float:p_max, Float:lateral_max, direction_change)
{
    if (!g_iNoRecoil)
        return HC_CONTINUE
    
    new id = get_member(pWeapon, m_pPlayer)
    
    if (!is_user_alive(id))
        return HC_CONTINUE

    if (CanApplyNorecoil(id))
    {
        return HC_SUPERCEDE
    }
    
    return HC_CONTINUE
}

// No-Spread
public OnFireBullets3_Pre(id, Float:vecSrc[3], Float:vecDirShooting[3], Float:vecSpread, Float:flDistance, iPenetration, iBulletType, iDamage, Float:flRangeModifier, pevAttacker, bool:bPistol, iSharedRand)
{
    if (!g_iNoSpread)
        return HC_CONTINUE
    
    if (!is_user_alive(id))
        return HC_CONTINUE
    
    if (CanApplyNorecoil(id))
    {
        SetHookChainArg(4, ATYPE_FLOAT, 0.0)
    }
    
    return HC_CONTINUE
}

bool:CanApplyNorecoil(id)
{
    if (!is_user_bot(id))
        return false
    
    new flags = get_entvar(id, var_flags)
    if (flags & FL_DUCKING)
        return false
        
    new Float:vVel[3]
    get_entvar(id, var_velocity, vVel)

    const Float:MIN_RUN_SPEED = 135.0
    
    return (vVel[0] * vVel[0] + vVel[1] * vVel[1]) > (MIN_RUN_SPEED * MIN_RUN_SPEED)
}
