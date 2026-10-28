UnitTemplate = Import("scom/units/ues5029/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5029", "SCOM unit identity mismatch: ues5029")
