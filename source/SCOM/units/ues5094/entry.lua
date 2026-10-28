UnitTemplate = Import("scom/units/ues5094/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5094", "SCOM unit identity mismatch: ues5094")
