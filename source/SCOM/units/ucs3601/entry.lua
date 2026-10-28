UnitTemplate = Import("scom/units/ucs3601/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3601", "SCOM unit identity mismatch: ucs3601")
