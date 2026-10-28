UnitTemplate = Import("scom/units/uga1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uga1001", "SCOM unit identity mismatch: uga1001")
