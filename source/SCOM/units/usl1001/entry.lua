UnitTemplate = Import("scom/units/usl1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usl1001", "SCOM unit identity mismatch: usl1001")
