-----------------------------------
--  MOB: Pelican
-- Area: Nyzul Isle
-- Info: NM
-----------------------------------
require("scripts/globals/nyzul")
require("scripts/globals/additional_effects")
require("scripts/globals/status")
-----------------------------------
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
 end

entity.onAdditionalEffect = function(mob, target, damage)
    return xi.mob.onAddEffect(mob, player, 0, xi.mob.ae.PETRIFY)
end

entity.onMobDeath = function(mob, player, isKiller, noKiller)
    if isKiller or noKiller then
        xi.nyzul.spawnChest(mob, player)
        xi.nyzul.eliminateAllKill(mob)
    end
end

return entity