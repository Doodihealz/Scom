UnitTemplate = Import("scom/units/ugs4902/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs4902", "SCOM unit identity mismatch: ugs4902")
