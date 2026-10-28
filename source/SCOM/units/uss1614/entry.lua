UnitTemplate = Import("scom/units/uss1614/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss1614", "SCOM unit identity mismatch: uss1614")
