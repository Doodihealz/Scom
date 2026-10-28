UnitTemplate = Import("scom/units/uss5005/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uss5005", "SCOM unit identity mismatch: uss5005")
