UnitTemplate = Import("scom/units/uel5009/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel5009", "SCOM unit identity mismatch: uel5009")
