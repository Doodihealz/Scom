UnitTemplate = Import("scom/units/ugs5033/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5033", "SCOM unit identity mismatch: ugs5033")
