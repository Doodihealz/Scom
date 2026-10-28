UnitTemplate = Import("scom/units/uss2806/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2806", "SCOM unit identity mismatch: uss2806")
