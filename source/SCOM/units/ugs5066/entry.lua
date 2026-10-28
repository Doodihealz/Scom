UnitTemplate = Import("scom/units/ugs5066/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5066", "SCOM unit identity mismatch: ugs5066")
