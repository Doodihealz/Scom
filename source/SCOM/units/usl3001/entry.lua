UnitTemplate = Import("scom/units/usl3001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl3001", "SCOM unit identity mismatch: usl3001")
