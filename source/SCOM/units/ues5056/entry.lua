UnitTemplate = Import("scom/units/ues5056/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5056", "SCOM unit identity mismatch: ues5056")
