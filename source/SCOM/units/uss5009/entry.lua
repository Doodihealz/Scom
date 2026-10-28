UnitTemplate = Import("scom/units/uss5009/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5009", "SCOM unit identity mismatch: uss5009")
