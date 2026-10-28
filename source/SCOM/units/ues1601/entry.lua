UnitTemplate = Import("scom/units/ues1601/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues1601", "SCOM unit identity mismatch: ues1601")
