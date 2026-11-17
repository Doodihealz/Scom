-- Scenery ownership is host authoritative; clients only register render/UI owners.
local Registry=Import("common/commands/registry.lua")
local Layouts=Import("common/commands/layouts.lua")
local Scenery=Import("common/systems/scoSceneryReclaim.lua")

SCOSceneryCreated=Registry.RegisterCommand(Registry.CommandChannel.HostToClient,{
    {key="entries",type=Layouts.Array({
        {key="id",type=Layouts.GlobalID},
        {key="tpId",type="string"},
        {key="progress",type="float"},
    })},
})
function SCOSceneryCreated.Send(entries) return {entries=entries} end
function SCOSceneryCreated.Receive(data) Scenery.ReceiveCreated(data.entries) end

SCOSceneryRemoved=Registry.RegisterCommand(Registry.CommandChannel.HostToClient,{
    {key="id",type=Layouts.GlobalID},
})
function SCOSceneryRemoved.Send(id) return {id=id} end
function SCOSceneryRemoved.Receive(data) Scenery.ReceiveRemoved(data.id) end

SCOSceneryProgress=Registry.RegisterCommand(Registry.CommandChannel.HostToClient,{
    {key="id",type=Layouts.GlobalID},{key="progress",type="float"},
})
function SCOSceneryProgress.Send(id,progress) return {id=id,progress=progress} end
function SCOSceneryProgress.Receive(data) Scenery.ReceiveProgress(data.id,data.progress) end
