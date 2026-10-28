UnitTemplate = Import("scom/units/ues3601/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues3601", "SCOM unit identity mismatch: ues3601")
