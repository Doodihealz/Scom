UnitTemplate = Import("scom/units/uea5010/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea5010", "SCOM unit identity mismatch: uea5010")
