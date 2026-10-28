UnitTemplate = Import("scom/units/ues5061/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5061", "SCOM unit identity mismatch: ues5061")
