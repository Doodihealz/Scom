UnitTemplate = Import("scom/units/usa3701/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "usa3701", "SCOM unit identity mismatch: usa3701")
