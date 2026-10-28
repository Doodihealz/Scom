UnitTemplate = Import("scom/units/ues5044/template.lua").UnitTemplate
assert(type(UnitTemplate) == "table" and UnitTemplate.general and UnitTemplate.general.tpId == "ues5044", "SCOM unit identity mismatch: ues5044")
