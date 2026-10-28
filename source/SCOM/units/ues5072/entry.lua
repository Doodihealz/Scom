UnitTemplate = Import("scom/units/ues5072/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5072", "SCOM unit identity mismatch: ues5072")
