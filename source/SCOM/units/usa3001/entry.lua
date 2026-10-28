UnitTemplate = Import("scom/units/usa3001/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usa3001", "SCOM unit identity mismatch: usa3001")
