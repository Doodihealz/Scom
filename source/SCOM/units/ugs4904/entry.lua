UnitTemplate = Import("scom/units/ugs4904/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs4904", "SCOM unit identity mismatch: ugs4904")
