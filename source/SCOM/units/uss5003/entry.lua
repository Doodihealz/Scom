UnitTemplate = Import("scom/units/uss5003/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5003", "SCOM unit identity mismatch: uss5003")
