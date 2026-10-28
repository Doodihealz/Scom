UnitTemplate = Import("scom/units/ugs5007/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5007", "SCOM unit identity mismatch: ugs5007")
