UnitTemplate = Import("scom/units/ues5015/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5015", "SCOM unit identity mismatch: ues5015")
