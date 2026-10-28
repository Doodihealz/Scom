UnitTemplate = Import("scom/units/uea1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea1001", "SCOM unit identity mismatch: uea1001")
