UnitTemplate = Import("scom/units/ues5075/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5075", "SCOM unit identity mismatch: ues5075")
