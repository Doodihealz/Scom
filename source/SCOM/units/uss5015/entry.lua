UnitTemplate = Import("scom/units/uss5015/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5015", "SCOM unit identity mismatch: uss5015")
