UnitTemplate = Import("scom/units/ues5054/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5054", "SCOM unit identity mismatch: ues5054")
