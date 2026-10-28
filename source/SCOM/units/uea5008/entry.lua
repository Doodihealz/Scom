UnitTemplate = Import("scom/units/uea5008/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea5008", "SCOM unit identity mismatch: uea5008")
