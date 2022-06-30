---------------------------------------------
--       Dynamis-Valkurm Mobskills         --
---------------------------------------------
---------------------------------------------
--        Module Required Scripts          --
---------------------------------------------
require("scripts/globals/dynamis")
require("modules/era/lua/dynamis/globals/era_dynamis")
require("modules/era/lua/dynamis/globals/era_dynamis_spawning")
require("modules/module_utils")
---------------------------------------------
local m = Module:new("era_valkurm_tp_moves")

m:addOverride("xi.globals.mobskills.attractant.onMobWeaponSkill", function(target, mob, skill)
    local typeEffect = xi.effect.CHARM_I
    local power = 0

    if (not target:isPC()) then
        skill:setMsg(xi.msg.basic.SKILL_MISS)
        return typeEffect
    end

    local msg = MobStatusEffectMove(mob, target, typeEffect, power, 3, 60)
    if (msg == xi.msg.basic.SKILL_ENFEEB_IS) then
        mob:charm(target)
        mob:resetEnmity(target)
    end
    skill:setMsg(msg)

    return typeEffect
end)

m:addOverride("xi.globals.mobskills.fragrant_breath.onMobWeaponSkill", function(target, mob, skill)
    local typeEffect = xi.effect.CHARM_I
    local power = 0
    local duration = 60
    if mob:getLocalVar("fragrantbreathduration") ~= nil then
        duration = mob:getLocalVar("fragrantbreathduration")
    end

    if (not target:isPC()) then
        skill:setMsg(xi.msg.basic.SKILL_MISS)
        return typeEffect
    end

    local msg = MobStatusEffectMove(mob, target, typeEffect, power, 3, duration)
    if (msg == xi.msg.basic.SKILL_ENFEEB_IS) then
        mob:charm(target)
        mob:resetEnmity(target)
    end
    skill:setMsg(msg)

    return typeEffect
end)

m:addOverride("xi.globals.mobskills.miasmic_breath.onMobWeaponSkill", function(target, mob, skill)
    local typeEffect = xi.effect.POISON
    local power = mob:getLocalVar("miasmicbreathpower")

    MobStatusEffectMove(mob, target, typeEffect, power, 3, 60)

    local dmgmod = MobBreathMove(mob, target, 0.1, 1.25, xi.magic.ele.WATER, 200)

    local dmg = MobFinalAdjustments(dmgmod, mob, skill, target, xi.attackType.BREATH, xi.damageType.WATER, MOBPARAM_IGNORE_SHADOWS)
    target:takeDamage(dmg, mob, xi.attackType.BREATH, xi.damageType.WATER)
    return dmg
end)

m:addOverride("xi.globals.mobskills.putrid_breath.onMobWeaponSkill", function(target, mob, skill)
    local cap = mob:getLocalVar("putridbreathcap")
    local dmgmod = MobBreathMove(mob, target, 0.15, 3, xi.magic.ele.EARTH, cap)
    local dmg = MobFinalAdjustments(dmgmod, mob, skill, target, xi.attackType.BREATH, xi.damageType.EARTH, MOBPARAM_IGNORE_SHADOWS)

    target:takeDamage(dmg, mob, xi.attackType.BREATH, xi.damageType.EARTH)
    return dmg
end)

m:addOverride("xi.globals.mobskills.soporific.onMobWeaponSkill", function(target, mob, skill)
    if mob:getZoneID() == xi.zone.DYNAMIS_VALKURM then
        local effect = xi.effect.SLEEP_I
        local resist = xi.mobskills.applyPlayerResistance(mob, nil, target, mob:getStat(xi.mod.INT)-target:getStat(xi.mod.INT), 1, xi.magic.ele.DARK)

        local duration = math.ceil(60 + math.floor(31*math.random()) * resist) -- wiki: duration variable from 30 to 90. can be thought of random 60-90 with possible half resist making it range 30-90
        if resist >= 0.5 then
            target:delStatusEffectSilent(effect)
            target:delStatusEffectSilent(xi.effect.LULLABY)
            target:delStatusEffectSilent(xi.effect.SLEEP_I)
            target:delStatusEffectSilent(xi.effect.POISON)
            local dotdmg = 50
            if not (target:hasImmunity(1) or hasSleepEffects(target)) and target:addStatusEffect(effect, 1, 0, duration, 25, 25, 1) then -- subid/subpower for poison detection on wakup function
                target:addStatusEffect(xi.effect.POISON, dotdmg, 3, duration, 0, 15, 2)
                skill:setMsg(xi.msg.basic.SKILL_ENFEEB_IS)
            else
                skill:setMsg(xi.msg.basic.SKILL_NO_EFFECT)
            end
        else
            skill:setMsg(xi.msg.basic.SKILL_MISS)
        end

        return effect
    else
        local typeEffect = xi.effect.SLEEP_I

        skill:setMsg(MobStatusEffectMove(mob, target, typeEffect, 1, 0, 30))

        return typeEffect
    end
end)

m:addOverride("xi.globals.mobskills.vampiric_lash.onMobWeaponSkill", function(target, mob, skill)
    local dmgmod = 1
    if mob:getLocalVar("vampiriclashpower") ~= nil then
        dmgmod = mob:getLocalVar("vampiriclashpower")
    end
    local info = xi.mobskills.mobMagicalMove(mob, target, skill, mob:getWeaponDmg()*3, xi.magic.ele.DARK, dmgmod, xi.mobskills.magicalTpBonus.NO_EFFECT)
    local dmg = xi.mobskills.mobFinalAdjustments(info.dmg, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.DARK, xi.mobskills.shadowBehavior.NUMSHADOWS_1)
    skill:setMsg(xi.mobskills.mobPhysicalDrainMove(mob, target, skill, xi.mobskills.drainType.HP, dmg))
    return dmg
end)

return m