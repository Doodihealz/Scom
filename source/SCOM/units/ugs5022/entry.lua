UnitTemplate = Import("scom/units/ugs5022/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5022", "SCOM unit identity mismatch: ugs5022")
