UnitTemplate = Import("scom/units/ucs3511/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3511", "SCOM unit identity mismatch: ucs3511")
