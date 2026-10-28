UnitTemplate = Import("scom/units/ucs1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs1001", "SCOM unit identity mismatch: ucs1001")
