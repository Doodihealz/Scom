UnitTemplate = Import("scom/units/ues5079/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5079", "SCOM unit identity mismatch: ues5079")
