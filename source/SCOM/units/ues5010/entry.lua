UnitTemplate = Import("scom/units/ues5010/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5010", "SCOM unit identity mismatch: ues5010")
