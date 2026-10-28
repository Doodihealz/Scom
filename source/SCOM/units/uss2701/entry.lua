UnitTemplate = Import("scom/units/uss2701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2701", "SCOM unit identity mismatch: uss2701")
