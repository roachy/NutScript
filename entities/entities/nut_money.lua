AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Money"
ENT.Author = "Chessnut"
ENT.Category = "NutScript"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel(nut.config.moneyModel)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetNetVar("amount", 0)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:Wake()
		end
	end

	function ENT:SetMoney(amount)
		if (amount <= 0) then
			self:Remove()
		end

		self:SetNetVar("amount", amount)
	end

	function ENT:Use(activator)
		local amount = self:GetNetVar("amount", 0)

		if (amount > 0 and IsValid(activator) and activator:IsPlayer()) then
			activator:GiveMoney(amount)
			nut.util.Notify("You have picked up "..nut.currency.GetName(amount)..".", activator)

			self:Remove()
		end
	end
end