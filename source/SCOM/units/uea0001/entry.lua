UnitTemplate = Import("scom/units/uea0001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea0001", "SCOM unit identity mismatch: uea0001")
