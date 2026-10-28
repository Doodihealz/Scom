UnitTemplate = Import("scom/units/uea5007/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea5007", "SCOM unit identity mismatch: uea5007")
