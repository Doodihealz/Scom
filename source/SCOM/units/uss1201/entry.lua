UnitTemplate = Import("scom/units/uss1201/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss1201", "SCOM unit identity mismatch: uss1201")
