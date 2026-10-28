UnitTemplate = Import("scom/units/uea5009/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea5009", "SCOM unit identity mismatch: uea5009")
