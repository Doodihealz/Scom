UnitTemplate = Import("scom/units/uea5003/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea5003", "SCOM unit identity mismatch: uea5003")
