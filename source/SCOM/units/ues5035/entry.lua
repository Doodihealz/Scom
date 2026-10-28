UnitTemplate = Import("scom/units/ues5035/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5035", "SCOM unit identity mismatch: ues5035")
