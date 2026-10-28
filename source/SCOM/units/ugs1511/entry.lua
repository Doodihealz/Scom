UnitTemplate = Import("scom/units/ugs1511/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs1511", "SCOM unit identity mismatch: ugs1511")
