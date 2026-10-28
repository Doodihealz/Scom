UnitTemplate = Import("scom/units/ues5069/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5069", "SCOM unit identity mismatch: ues5069")
