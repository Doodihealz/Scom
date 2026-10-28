UnitTemplate = Import("scom/units/uss1513/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss1513", "SCOM unit identity mismatch: uss1513")
