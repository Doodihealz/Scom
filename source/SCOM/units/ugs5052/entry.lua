UnitTemplate = Import("scom/units/ugs5052/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5052", "SCOM unit identity mismatch: ugs5052")
