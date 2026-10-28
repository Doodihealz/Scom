UnitTemplate = Import("scom/units/ues5062/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5062", "SCOM unit identity mismatch: ues5062")
