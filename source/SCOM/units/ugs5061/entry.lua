UnitTemplate = Import("scom/units/ugs5061/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5061", "SCOM unit identity mismatch: ugs5061")
