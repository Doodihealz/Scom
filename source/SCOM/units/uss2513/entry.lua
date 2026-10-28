UnitTemplate = Import("scom/units/uss2513/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss2513", "SCOM unit identity mismatch: uss2513")
