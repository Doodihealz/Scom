UnitTemplate = Import("scom/units/ues5021/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5021", "SCOM unit identity mismatch: ues5021")
