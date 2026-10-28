UnitTemplate = Import("scom/units/ucs3001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3001", "SCOM unit identity mismatch: ucs3001")
