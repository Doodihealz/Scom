UnitTemplate = Import("scom/units/ucs3611/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3611", "SCOM unit identity mismatch: ucs3611")
