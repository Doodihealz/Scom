UnitTemplate = Import("scom/units/uel5006/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel5006", "SCOM unit identity mismatch: uel5006")
