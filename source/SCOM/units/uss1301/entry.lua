UnitTemplate = Import("scom/units/uss1301/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss1301", "SCOM unit identity mismatch: uss1301")
