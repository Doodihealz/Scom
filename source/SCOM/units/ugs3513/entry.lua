UnitTemplate = Import("scom/units/ugs3513/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs3513", "SCOM unit identity mismatch: ugs3513")
