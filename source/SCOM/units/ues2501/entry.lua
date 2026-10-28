UnitTemplate = Import("scom/units/ues2501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues2501", "SCOM unit identity mismatch: ues2501")
