AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Item"
ENT.Category = "NutScript"
ENT.Author = "Chessnut"

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "InternalData")
	self:NetworkVar("String", 1, "ItemID")
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_junk/watermelon01.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:EnableMotion(true)
			physicsObject:Wake()
		end
	end

	function ENT:Use(activator)
		if (nut.schema.Call("PlayerCanUseItem", activator, self) != false) then
			netstream.Start(activator, "nut_ShowItemMenu", self)
		end
	end
end

function ENT:GetData()
	if (self:GetInternalData()) then
		if (!self.realData) then
			self.realData = von.deserialize(self:GetInternalData())
		end

		return self.realData
	end
end

function ENT:GetItemTable()
	if (self:GetItemID()) then
		if (!self.itemTable) then
			self.itemTable = nut.item.Get(self:GetItemID())
		end

		return self.itemTable
	end
end