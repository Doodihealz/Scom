UnitTemplate = Import("scom/units/ugs5065/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5065", "SCOM unit identity mismatch: ugs5065")
