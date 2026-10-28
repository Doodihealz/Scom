UnitTemplate = Import("scom/units/ues1513/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues1513", "SCOM unit identity mismatch: ues1513")
