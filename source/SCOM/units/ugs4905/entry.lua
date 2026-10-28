UnitTemplate = Import("scom/units/ugs4905/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs4905", "SCOM unit identity mismatch: ugs4905")
