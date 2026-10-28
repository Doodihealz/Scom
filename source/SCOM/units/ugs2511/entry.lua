UnitTemplate = Import("scom/units/ugs2511/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs2511", "SCOM unit identity mismatch: ugs2511")
