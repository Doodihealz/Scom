UnitTemplate = Import("scom/units/usa1001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usa1001", "SCOM unit identity mismatch: usa1001")
