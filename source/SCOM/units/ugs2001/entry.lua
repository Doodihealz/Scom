UnitTemplate = Import("scom/units/ugs2001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs2001", "SCOM unit identity mismatch: ugs2001")
