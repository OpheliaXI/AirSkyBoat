----------------------------------------------------------------
-- Claim Shield Mixin
-- Used to add Claim Shield to a mob without overwriting
-- the onSpawn() function.
----------------------------------------------------------------

require("scripts/globals/mixins")

g_mixins = g_mixins or {}

local claimshieldTime = 7500

g_mixins.claim_shield = function(claimshieldMob)

    claimshieldMob:addListener("SPAWN", "CS_SPAWN", function(mob)
        mob:setClaimable(false)
        mob:setUnkillable(true)
        mob:setCallForHelpBlocked(true)
        mob:stun(claimshieldTime)

        mob:timer(claimshieldTime, function(mobArg)
            local enmityList = mobArg:getEnmityList()

            mobArg:setClaimable(true)
            mobArg:setUnkillable(false)
            mobArg:setCallForHelpBlocked(false)

            mobArg:resetAI()
            mobArg:setHP(mobArg:getMaxHP())

            local winner = utils.randomEntry(enmityList)["entity"]
            if winner then
                mobArg:updateClaim(winner)
            end
        end)
    end)
end

return g_mixins.claim_shield
