UnitTemplate = Import("scom/units/uss5006/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5006", "SCOM unit identity mismatch: uss5006")
