UnitTemplate = Import("scom/units/uel5008/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel5008", "SCOM unit identity mismatch: uel5008")
