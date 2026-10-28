UnitTemplate = Import("scom/units/ues5020/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5020", "SCOM unit identity mismatch: ues5020")
