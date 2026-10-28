UnitTemplate = Import("scom/units/ues5007/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5007", "SCOM unit identity mismatch: ues5007")
