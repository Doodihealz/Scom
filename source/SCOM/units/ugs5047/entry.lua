UnitTemplate = Import("scom/units/ugs5047/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5047", "SCOM unit identity mismatch: ugs5047")
