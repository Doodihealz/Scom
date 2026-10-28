UnitTemplate = Import("scom/units/ues5074/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5074", "SCOM unit identity mismatch: ues5074")
