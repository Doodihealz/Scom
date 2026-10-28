UnitTemplate = Import("scom/units/uss5004/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5004", "SCOM unit identity mismatch: uss5004")
