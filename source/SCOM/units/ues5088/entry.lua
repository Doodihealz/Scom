UnitTemplate = Import("scom/units/ues5088/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5088", "SCOM unit identity mismatch: ues5088")
