UnitTemplate = Import("scom/units/uea5011/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea5011", "SCOM unit identity mismatch: uea5011")
