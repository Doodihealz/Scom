UnitTemplate = Import("scom/units/ugs5062/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5062", "SCOM unit identity mismatch: ugs5062")
