UnitTemplate = Import("scom/units/uel4511/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "uel4511", "SCOM unit identity mismatch: uel4511")
