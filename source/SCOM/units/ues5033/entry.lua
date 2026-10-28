UnitTemplate = Import("scom/units/ues5033/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5033", "SCOM unit identity mismatch: ues5033")
