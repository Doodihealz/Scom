UnitTemplate = Import("scom/units/ucs3402/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3402", "SCOM unit identity mismatch: ucs3402")
