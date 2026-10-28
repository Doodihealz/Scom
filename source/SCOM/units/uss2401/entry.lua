UnitTemplate = Import("scom/units/uss2401/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2401", "SCOM unit identity mismatch: uss2401")
