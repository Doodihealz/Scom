UnitTemplate = Import("scom/units/usl3501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl3501", "SCOM unit identity mismatch: usl3501")
