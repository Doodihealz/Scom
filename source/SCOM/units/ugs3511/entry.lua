UnitTemplate = Import("scom/units/ugs3511/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs3511", "SCOM unit identity mismatch: ugs3511")
