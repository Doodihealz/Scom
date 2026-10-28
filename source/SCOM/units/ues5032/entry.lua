UnitTemplate = Import("scom/units/ues5032/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5032", "SCOM unit identity mismatch: ues5032")
