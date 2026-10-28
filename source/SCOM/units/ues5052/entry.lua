UnitTemplate = Import("scom/units/ues5052/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5052", "SCOM unit identity mismatch: ues5052")
