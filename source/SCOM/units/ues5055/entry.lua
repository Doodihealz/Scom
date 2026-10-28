UnitTemplate = Import("scom/units/ues5055/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5055", "SCOM unit identity mismatch: ues5055")
