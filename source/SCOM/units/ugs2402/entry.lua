UnitTemplate = Import("scom/units/ugs2402/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs2402", "SCOM unit identity mismatch: ugs2402")
