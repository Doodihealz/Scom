using System;

namespace SupremeCommanderOverhaulCanonical;

internal static class NavalWreckPresentationPolicy
{
	private const string CommandMarker = "-- SCOM naval wreck presentation 1.0.0";

	private const string HostMarker = "-- SCOM naval wreck reclaim and lifetime 1.0.0";

	internal static string PatchCommands(string source)
	{
		source = source.Replace("\r\n", "\n");
		if (source.Contains("-- SCOM naval wreck presentation 1.1.0"))
		{
			return source;
		}
		if (!source.Contains("local Props = __Entities.Props") || !source.Contains("function CreateProp.Receive(data)"))
		{
			throw new InvalidOperationException("Naval wreck command source contract changed.");
		}
		return source + "\n-- SCOM naval wreck presentation 1.1.0\nSCO_NavalWreckPhase = Registry.RegisterCommand(Registry.CommandChannel.HostToClient, {\n    { key = \"propID\", type = Layouts.GlobalID },\n    { key = \"settled\", type = \"bool\" },\n    { key = \"sourceUnitID\", type = Layouts.GlobalID },\n})\n\nfunction SCO_NavalWreckPhase.Send(propID, settled, sourceUnitID)\n    return {\n        propID = propID,\n        settled = settled,\n        sourceUnitID = sourceUnitID or propID,\n    }\nend\n\n-- The collider continues to own reclaim interaction after settlement. Only\n-- this wreck's decorative renderer is permanently retired.\nlocal function SCO_NavalWreckSetSelectionBracketEnabled(prop)\n    if prop.selectionBracketID then\n        Engine.SetRendererEnabled(prop.selectionBracketID, false)\n    end\nend\n\nfunction SCO_NavalWreckPhase.Receive(data)\n    local prop = Props[data.propID.index]\n    if not prop or prop.deleted then return end\n    prop.SetSelectionBracketEnabled = SCO_NavalWreckSetSelectionBracketEnabled\n    prop:SetSelectionBracketEnabled(false)\n\n    -- Only the initial SCOM naval-sinking phase carries a distinct source unit.\n    -- Copy while that renderer is still paired; the later unit deletion must not\n    -- reset the wreck to its template's neutral color.\n    local sourceID = data.sourceUnitID\n    local hasDistinctSource = not data.settled and sourceID\n        and (sourceID.index ~= data.propID.index\n            or sourceID.version ~= data.propID.version)\n    if hasDistinctSource then\n        local sourceResult, sourceLocalID =\n            Engine.GetGlobalEntityPairedLocalID(sourceID)\n        if sourceResult == EngineErrorCode.Success then\n            local colorResult, teamColor =\n                Engine.GetRendererInstanceData0(sourceLocalID)\n            if colorResult == EngineErrorCode.Success and teamColor then\n                Engine.SetRendererInstanceData0(prop.localId, teamColor)\n            end\n        end\n    end\n\n    local _, instanceData = Engine.GetRendererInstanceData1(prop.localId)\n    instanceData.y = data.settled and 1 or 0\n    Engine.SetRendererInstanceData1(prop.localId, instanceData)\n\n    prop.isSelectable = data.settled\n    -- Prop selection is on the root, unlike the unit's Selection Collider bone.\n    Engine.SetVolumeColliderEnabled(prop.localId, data.settled)\nend\n";
	}

	internal static string PatchHostWreck(string source)
	{
		source = source.Replace("\r\n", "\n");
		if (source.Contains("-- SCOM naval wreck reclaim and lifetime 1.0.0"))
		{
			return source;
		}
		int num = source.IndexOf("        WaitSeconds(180)\n        self:Delete()", StringComparison.Ordinal);
		if (num < 0 || source.IndexOf("        WaitSeconds(180)\n        self:Delete()", num + "        WaitSeconds(180)\n        self:Delete()".Length, StringComparison.Ordinal) >= 0)
		{
			throw new InvalidOperationException("Naval wreck cleanup source contract changed.");
		}
		source = source.Replace("        WaitSeconds(180)\n        self:Delete()", "        -- Creation returns before the crash owner can mark the naval wreck.\n        WaitTicks(1)\n        local naval = self.scoNavalSinking == true\n        while self.scoNavalSinking do\n            WaitTicks(1)\n        end\n        WaitSeconds(naval and 180 or (180 - Constants.TickTimeStep))\n        self:Delete()");
		return "-- SCOM naval wreck reclaim and lifetime 1.0.0\n" + source + "\nfunction HostWreckage:CanStartReclaimProcess()\n    return not self.scoNavalSinking and Reclaimable.CanStartReclaimProcess(self)\nend\n\nfunction HostWreckage:CanContinueReclaimProcess()\n    return not self.scoNavalSinking and Reclaimable.CanContinueReclaimProcess(self)\nend\n";
	}
}
