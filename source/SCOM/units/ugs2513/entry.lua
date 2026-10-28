UnitTemplate = Import("scom/units/ugs2513/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs2513", "SCOM unit identity mismatch: ugs2513")
