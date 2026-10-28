UnitTemplate = Import("scom/units/uea5002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea5002", "SCOM unit identity mismatch: uea5002")
