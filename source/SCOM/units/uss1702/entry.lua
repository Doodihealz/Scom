UnitTemplate = Import("scom/units/uss1702/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss1702", "SCOM unit identity mismatch: uss1702")
