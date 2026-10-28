UnitTemplate = Import("scom/units/uea5005/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea5005", "SCOM unit identity mismatch: uea5005")
