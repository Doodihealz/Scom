UnitTemplate = Import("scom/units/ugs1513/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs1513", "SCOM unit identity mismatch: ugs1513")
