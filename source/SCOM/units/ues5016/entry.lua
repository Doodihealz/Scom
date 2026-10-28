UnitTemplate = Import("scom/units/ues5016/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5016", "SCOM unit identity mismatch: ues5016")
