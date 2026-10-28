UnitTemplate = Import("scom/units/ues5023/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5023", "SCOM unit identity mismatch: ues5023")
