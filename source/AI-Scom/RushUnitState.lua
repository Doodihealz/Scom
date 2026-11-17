-- Pause is a capability of a unit's toggle state, not of its base-class methods.
-- Combat units can inherit GetPause/SetPause without owning a toggles table.
-- Never synthesize that table: the host owns toggle initialization and events.
Version = "1.0.0"

function IsPaused(unit)
    local toggles = unit and unit.toggles
    if type(toggles) ~= "table" then return false end
    if type(unit.GetPause) == "function" then return not not unit:GetPause() end
    return not not toggles.Pause
end

function CanPause(unit)
    return unit ~= nil and type(unit.toggles) == "table" and type(unit.SetPause) == "function"
end
