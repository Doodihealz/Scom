UnitTemplate = Import("scom/units/ues2511/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues2511", "SCOM unit identity mismatch: ues2511")
