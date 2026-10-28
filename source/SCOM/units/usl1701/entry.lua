UnitTemplate = Import("scom/units/usl1701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl1701", "SCOM unit identity mismatch: usl1701")
