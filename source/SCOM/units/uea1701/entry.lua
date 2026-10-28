UnitTemplate = Import("scom/units/uea1701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uea1701", "SCOM unit identity mismatch: uea1701")
