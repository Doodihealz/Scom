UnitTemplate = Import("scom/units/ugs5043/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5043", "SCOM unit identity mismatch: ugs5043")
