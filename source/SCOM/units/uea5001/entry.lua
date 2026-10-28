UnitTemplate = Import("scom/units/uea5001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea5001", "SCOM unit identity mismatch: uea5001")
