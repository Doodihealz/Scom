UnitTemplate = Import("scom/units/ugs5059/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5059", "SCOM unit identity mismatch: ugs5059")
