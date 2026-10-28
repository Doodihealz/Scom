UnitTemplate = Import("scom/units/usa2301/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usa2301", "SCOM unit identity mismatch: usa2301")
