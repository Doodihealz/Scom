UnitTemplate = Import("scom/units/ugs5020/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5020", "SCOM unit identity mismatch: ugs5020")
