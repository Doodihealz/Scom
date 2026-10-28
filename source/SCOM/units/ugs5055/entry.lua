UnitTemplate = Import("scom/units/ugs5055/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5055", "SCOM unit identity mismatch: ugs5055")
