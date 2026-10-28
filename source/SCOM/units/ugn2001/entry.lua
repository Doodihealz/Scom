UnitTemplate = Import("scom/units/ugn2001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugn2001", "SCOM unit identity mismatch: ugn2001")
