UnitTemplate = Import("scom/units/ugs5019/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5019", "SCOM unit identity mismatch: ugs5019")
