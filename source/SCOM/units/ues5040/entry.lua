UnitTemplate = Import("scom/units/ues5040/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5040", "SCOM unit identity mismatch: ues5040")
