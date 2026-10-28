UnitTemplate = Import("scom/units/ugn5001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugn5001", "SCOM unit identity mismatch: ugn5001")
