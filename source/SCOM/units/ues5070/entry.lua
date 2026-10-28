UnitTemplate = Import("scom/units/ues5070/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5070", "SCOM unit identity mismatch: ues5070")
