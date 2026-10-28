UnitTemplate = Import("scom/units/ues5065/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5065", "SCOM unit identity mismatch: ues5065")
