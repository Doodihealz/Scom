-- Private unit classes share methods, but own their mutable member tables.
function Derive(name, base)
    assert(base, "Missing shared unit class: " .. name)
    local child = Class(name, base)
    local meta = debug.getmetatable(base)
    for key, value in meta.__pairs(base) do
        if type(value) == "table" and key ~= "__class" then
            child[key] = table.deepCopy(value)
        end
    end
    return child
end
