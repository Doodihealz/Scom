UnitTemplate = Import("scom/units/ues5034/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5034", "SCOM unit identity mismatch: ues5034")
