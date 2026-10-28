UnitTemplate = Import("scom/units/uss1611/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss1611", "SCOM unit identity mismatch: uss1611")
