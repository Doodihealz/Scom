UnitTemplate = Import("scom/units/uss2001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2001", "SCOM unit identity mismatch: uss2001")
