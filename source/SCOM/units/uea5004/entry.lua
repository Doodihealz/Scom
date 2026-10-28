UnitTemplate = Import("scom/units/uea5004/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea5004", "SCOM unit identity mismatch: uea5004")
