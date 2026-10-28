UnitTemplate = Import("scom/units/ues5037/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5037", "SCOM unit identity mismatch: ues5037")
