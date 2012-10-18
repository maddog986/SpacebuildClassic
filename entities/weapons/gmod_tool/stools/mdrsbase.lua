if (!beams) || (!RS) then return end

RS:AddTools()

TOOL				= ToolObj:Create()
TOOL.Category		= "MadDog's Systems"
TOOL.Mode			= "mdrsbase"
TOOL.Name			= "mdrsbase"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.AddToMenu 		= false