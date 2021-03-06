AddCSLuaFile()

local PLUGIN = PLUGIN

ENT.Type = "anim"
ENT.PrintName = "Vendor"
ENT.Author = "Chessnut"
ENT.Spawnable = true
ENT.Category = "NutScript"

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/mossman.mdl")
		self:SetUseType(SIMPLE_USE)
		self:SetMoveType(MOVETYPE_NONE)
		self:DrawShadow(true)
		self:SetSolid(SOLID_BBOX)
		self:PhysicsInit(SOLID_BBOX)
		self:DropToFloor()

		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:EnableMotion(false)
			physicsObject:Sleep()
		end
	else
		self:CreateBubble()
	end

	self:SetAnim()
end

function ENT:SetAnim()
	for k, v in pairs(self:GetSequenceList()) do
		if (string.find(string.lower(v), "idle")) then
			if (v != "idlenoise") then
				self:ResetSequence(k)

				return
			end
		end
	end

	self:ResetSequence(4)
end

if (CLIENT) then
	function ENT:CreateBubble()
		self.bubble = ClientsideModel("models/extras/info_speech.mdl", RENDERGROUP_OPAQUE)
		self.bubble:SetPos(self:GetPos() + Vector(0, 0, 84))
		self.bubble:SetModelScale(0.6, 0)
	end

	function ENT:Think()
		if (!IsValid(self.bubble)) then
			self:CreateBubble()
		end

		self:SetEyeTarget(LocalPlayer():GetPos())
	end

	function ENT:Draw()
		local bubble = self.bubble

		if (IsValid(bubble)) then
			local realTime = RealTime()

			bubble:SetAngles(Angle(0, realTime * 120, 0))
			bubble:SetRenderOrigin(self:GetPos() + Vector(0, 0, 84 + math.sin(realTime * 3) * 0.03))
		end

		self:DrawModel()
	end

	function ENT:OnRemove()
		if (IsValid(self.bubble)) then
			self.bubble:Remove()
		end
	end

	netstream.Hook("nut_Vendor", function(data)
		if (IsValid(nut.gui.vendor)) then
			nut.gui.vendor:Remove()

			return
		end

		nut.gui.vendor = vgui.Create("nut_Vendor")
		nut.gui.vendor:SetEntity(data)
	end)
else
	function ENT:Use(activator)
		netstream.Start(activator, "nut_Vendor", self)
	end

	netstream.Hook("nut_VendorData", function(client, data)
		if (!client:IsAdmin()) then
			return
		end

		local entity = data[1]
		local itemData = data[2]
		local factionData = data[3]
		local classData = data[4]
		local name = data[5]
		local desc = data[6]
		local model = data[7]
		
		if (IsValid(entity)) then
			entity:SetNetVar("data", itemData)
			entity:SetNetVar("factiondata", factionData)
			entity:SetNetVar("classdata", classData)
			entity:SetNetVar("name", name)
			entity:SetNetVar("desc", desc)
			entity:SetModel(model or entity:GetModel())
			entity:SetAnim()

			PLUGIN:SaveData()
			nut.util.Notify("You have updated this vendor's data.", client)
		end
	end)

	netstream.Hook("nut_VendorBuy", function(client, data)
		local entity = data[1]
		local class = data[2]
		local itemTable = nut.item.Get(class)

		if (!IsValid(entity) or entity:GetPos():Distance(client:GetPos()) > 128 or !itemTable) then
			return
		end

		local factionData = entity:GetNetVar("factiondata", {})

		if (!factionData[client:Team()]) then
			return
		end

		local classData = entity:GetNetVar("classdata", {})

		if (table.Count(classData) > 0 and !classData[client:CharClass()]) then
			return
		end

		local data = entity:GetNetVar("data", {})

		if (!data[class] or !data[class].selling) then
			return
		end

		local price = itemTable.price or 0

		if (data[class] and data[class].price) then
			price = data[class].price
		end

		if (client:CanAfford(price)) then
			client:UpdateInv(class)
			client:TakeMoney(price)

			nut.util.Notify(nut.lang.Get("purchased", itemTable.name), client)
		else
			nut.util.Notify(nut.lang.Get("no_afford"), client)
		end
	end)
end