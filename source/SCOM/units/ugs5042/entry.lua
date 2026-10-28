UnitTemplate = Import("scom/units/ugs5042/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5042", "SCOM unit identity mismatch: ugs5042")
