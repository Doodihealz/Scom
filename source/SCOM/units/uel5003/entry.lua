UnitTemplate = Import("scom/units/uel5003/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel5003", "SCOM unit identity mismatch: uel5003")
