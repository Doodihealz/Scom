UnitTemplate = Import("scom/units/uea5006/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea5006", "SCOM unit identity mismatch: uea5006")
