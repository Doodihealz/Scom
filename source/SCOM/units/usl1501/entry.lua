UnitTemplate = Import("scom/units/usl1501/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl1501", "SCOM unit identity mismatch: usl1501")
