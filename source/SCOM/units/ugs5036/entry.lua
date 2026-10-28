UnitTemplate = Import("scom/units/ugs5036/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5036", "SCOM unit identity mismatch: ugs5036")
