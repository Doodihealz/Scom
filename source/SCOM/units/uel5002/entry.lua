UnitTemplate = Import("scom/units/uel5002/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel5002", "SCOM unit identity mismatch: uel5002")
