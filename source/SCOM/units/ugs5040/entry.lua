UnitTemplate = Import("scom/units/ugs5040/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ugs5040", "SCOM unit identity mismatch: ugs5040")
