UnitTemplate = Import("scom/units/ugs1611/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs1611", "SCOM unit identity mismatch: ugs1611")
