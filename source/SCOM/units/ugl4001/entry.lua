UnitTemplate = Import("scom/units/ugl4001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugl4001", "SCOM unit identity mismatch: ugl4001")
