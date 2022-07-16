-----------------------------------
-- Aero 2
-----------------------------------
require("scripts/globals/settings")
require("scripts/globals/status")
require("scripts/globals/mobskills")
require("scripts/globals/magic")

-----------------------------------
local ability_object = {}

ability_object.onAbilityCheck = function(player, target, ability)
    return 0, 0
end

ability_object.onPetAbility = function(target, pet, skill)
    local dINT = math.floor(pet:getStat(xi.mod.INT) - target:getStat(xi.mod.INT))
    local tp = skill:getTP()
    local damage = 9

    if tp < 1500 then
        damage = math.floor(damage * (29/256) * (tp/10) + (928/256))
    else
        damage = math.floor(damage * ((29/256) * (1000/10)) + ((14/256) * ((tp-1000)/10)) + (928/256))
    end

    local damage = math.floor(325 + 0.025*(tp))
    damage = damage + (dINT * 1.5)
    damage = xi.mobskills.mobMagicalMove(pet, target, skill, damage, xi.magic.ele.FIRE, 1, xi.mobskills.magicalTpBonus.NO_EFFECT, 0)
    damage = xi.mobskills.mobAddBonuses(pet, target, damage.dmg, xi.magic.ele.FIRE)
    damage = xi.summon.avatarFinalAdjustments(damage, pet, skill, target, xi.attackType.MAGICAL, xi.damageType.FIRE, 1)

    target:takeDamage(damage, pet, xi.attackType.MAGICAL, xi.damageType.FIRE)
    target:updateEnmityFromDamage(pet, damage)

    return damage
end

return ability_object
