UnitTemplate = Import("scom/units/ues2402/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues2402", "SCOM unit identity mismatch: ues2402")
