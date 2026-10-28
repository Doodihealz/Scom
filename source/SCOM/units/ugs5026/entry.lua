UnitTemplate = Import("scom/units/ugs5026/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5026", "SCOM unit identity mismatch: ugs5026")
