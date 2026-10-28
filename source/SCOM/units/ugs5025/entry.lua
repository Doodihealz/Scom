UnitTemplate = Import("scom/units/ugs5025/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5025", "SCOM unit identity mismatch: ugs5025")
