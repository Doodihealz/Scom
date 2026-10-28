UnitTemplate = Import("scom/units/uss5008/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5008", "SCOM unit identity mismatch: uss5008")
