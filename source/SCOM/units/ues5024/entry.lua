UnitTemplate = Import("scom/units/ues5024/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5024", "SCOM unit identity mismatch: ues5024")
