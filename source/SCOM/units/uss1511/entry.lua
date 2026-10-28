UnitTemplate = Import("scom/units/uss1511/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss1511", "SCOM unit identity mismatch: uss1511")
