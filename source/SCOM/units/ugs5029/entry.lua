UnitTemplate = Import("scom/units/ugs5029/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5029", "SCOM unit identity mismatch: ugs5029")
