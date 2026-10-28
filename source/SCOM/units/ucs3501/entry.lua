UnitTemplate = Import("scom/units/ucs3501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ucs3501", "SCOM unit identity mismatch: ucs3501")
