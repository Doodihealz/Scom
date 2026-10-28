UnitTemplate = Import("scom/units/ugs5035/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5035", "SCOM unit identity mismatch: ugs5035")
