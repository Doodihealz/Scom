-- RC13: exact bounded selection. The caller supplies a deterministic total order.
-- The input is never mutated; all candidates are examined. The returned prefix
-- equals a full table.sort followed by truncation, without sorting the remainder.
Version = "9.0.12-rc13"
function Top(items, limit, less)
    limit = math.max(0, math.floor(limit or 0))
    local count = #items
    if limit == 0 or count == 0 then return {} end
    local result = {}
    if count <= limit then
        for i = 1, count do result[i] = items[i] end
    else
        -- Worst selected item at the root. Insertion/replacement is O(log k).
        for i = 1, count do
            local value = items[i]
            local n = #result
            if n < limit then
                n = n + 1
                local at = n
                while at > 1 do
                    local parent = math.floor(at / 2)
                    if not less(result[parent], value) then break end
                    result[at] = result[parent]
                    at = parent
                end
                result[at] = value
            elseif less(value, result[1]) then
                local at = 1
                while at * 2 <= n do
                    local child = at * 2
                    if child < n and less(result[child], result[child + 1]) then child = child + 1 end
                    if not less(value, result[child]) then break end
                    result[at] = result[child]
                    at = child
                end
                result[at] = value
            end
        end
    end
    table.sort(result, less)
    return result
end
