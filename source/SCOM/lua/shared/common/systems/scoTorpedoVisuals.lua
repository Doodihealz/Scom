-- Shared physical torpedo presentation. Damage, motion and impact effects stay
-- with each projectile; depth charges and anti-torpedo defenses are excluded.
local torpedoes = {
    pgr305t = true, pmg402 = true,
    psf0011 = true, psf0012 = true, psf0027 = true,
    psf0053 = true, psf0054 = true, psf0055 = true,
    psf0084 = true, psf0085 = true, psf0086 = true,
    psf0115 = true, psf0116 = true, psf0117 = true,
    psf0118 = true, psf0119 = true, psf0120 = true, psf0121 = true,
    psf0148 = true, psf0149 = true, psf0150 = true,
    psf0183 = true, psf0191 = true, psf0192 = true,
}

local function Apply(tp)
    if not (tp and tp.general and torpedoes[tp.general.tpId]) then return false end
    local visuals = assert(tp.visuals, 'Torpedo presentation requires projectile visuals')
    visuals.scoProjectileMesh = {
        model = 'Projectiles/psf0148/LOD0/psf0148.sanmodel',
        material = 'Projectiles/psf0148/LOD0/psf0148.sanmaterial',
        scale = { x = 1.5, y = 1.5, z = 1.5 },
    }
    -- One persistent wake component uses the native root owner. Clearing an
    -- older ribbon map prevents the loader from creating stale named owners.
    visuals.scoTrailOwners = nil
    visuals.persistantEffects = { { effects = {
        { particleName = 'VFX/SCOM/Source/psf0148/trail.sanvfx' },
    } } }
    return true
end

getfenv(1).Apply = Apply
return { Apply = Apply }
