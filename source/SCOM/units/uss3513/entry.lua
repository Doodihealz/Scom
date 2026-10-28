UnitTemplate = Import("scom/units/uss3513/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss3513", "SCOM unit identity mismatch: uss3513")
