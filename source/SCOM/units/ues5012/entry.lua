UnitTemplate = Import("scom/units/ues5012/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5012", "SCOM unit identity mismatch: ues5012")
