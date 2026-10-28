UnitTemplate = Import("scom/units/ues5046/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5046", "SCOM unit identity mismatch: ues5046")
