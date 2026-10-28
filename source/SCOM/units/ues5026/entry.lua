UnitTemplate = Import("scom/units/ues5026/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5026", "SCOM unit identity mismatch: ues5026")
