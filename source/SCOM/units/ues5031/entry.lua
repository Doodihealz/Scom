UnitTemplate = Import("scom/units/ues5031/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5031", "SCOM unit identity mismatch: ues5031")
