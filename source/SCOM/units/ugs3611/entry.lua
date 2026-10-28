UnitTemplate = Import("scom/units/ugs3611/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs3611", "SCOM unit identity mismatch: ugs3611")
