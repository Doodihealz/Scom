UnitTemplate = Import("scom/units/ues5017/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5017", "SCOM unit identity mismatch: ues5017")
