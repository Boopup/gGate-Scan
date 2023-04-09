--[[         This gate is made by @GalacticInspired, @B00PUP, and Whitehill Group           ]]
--[[               Design credits go to Wanzl, based off of the product eGate               ]]



local debounce = false
local scan_tool = "ID Card"
local alarmed = true
local open_time = 5
local open_speed = 3
local colors = {
	closed = Color3.fromRGB(0, 255, 0),
	open = Color3.fromRGB(0, 100, 255),
	alarm = Color3.fromRGB(255, 0, 0)
}


local triggered = false
local triggeredGates = {}
local operation = false

task.wait(5)

for i, v in pairs(script.Parent.Gates:GetDescendants()) do
	if v:IsA("BasePart") and v.Anchored == false then
		pcall(function()
			v:SetNetworkOwner(nil)
		end)
	end
end


for i, v in pairs(script.Parent.Gates:GetChildren()) do
	v.Gate.Hinge.HingeConstraint.AngularSpeed = open_speed
end

local function setColor(color)
	for i, v in pairs(script.Parent.Gates:GetChildren()) do
		if v.Name == "Right" then
			v.Gate.Glass.Color = color
			v.Gate.Light.Color = color
		elseif v.Name == "Left" then
			v.Gate.Glass.Color = color
			v.Gate.Light.Color = color
		end
	end
end

local function run()
	debounce = true
	operation = true
	for i, v in pairs(script.Parent.Gates:GetChildren()) do
		if v.Name == "Right" then
			v.Gate.Hinge.HingeConstraint.TargetAngle = 90
		elseif v.Name == "Left" then
			v.Gate.Hinge.HingeConstraint.TargetAngle = -90
		end
	end
	setColor(colors.open)
	task.wait(open_time)
	for i, v in pairs(script.Parent.Gates:GetChildren()) do
		if v.Name == "Right" then
			v.Gate.Hinge.HingeConstraint.TargetAngle = 0
		elseif v.Name == "Left" then
			v.Gate.Hinge.HingeConstraint.TargetAngle = 0
		end
	end
	setColor(colors.closed)
	debounce = false
	operation = false
end

script.Parent["Gate_Scanner"].Scanner.ScanField.Touched:Connect(function(touch)
	if touch.Parent.Name == scan_tool and debounce == false and triggered == false then

		run()


	end
end)


setColor(colors.closed)

if alarmed then
	while true do
		for i, v in pairs(script.Parent.Gates:GetChildren()) do
			if v.Name == "Right" then
				local Hinge = v.Gate.Hinge.HingeConstraint
				Hinge.AngularResponsiveness = (Hinge.TargetAngle > 0 and not triggered) and math.huge or 10
				if Hinge.CurrentAngle < -7.5 and not debounce and not table.find(triggeredGates, v) then
					triggered = true
					table.insert(triggeredGates, v)
					v.Pole.FakeSensor.Alarm:Play()
					setColor(colors.alarm)
					Hinge.AngularResponsiveness = math.huge
					Hinge.TargetAngle = Hinge.CurrentAngle
					task.delay(1, function()
						Hinge.TargetAngle = Hinge.CurrentAngle * 2
						task.wait(1)
						Hinge.TargetAngle = 0
						task.wait(1)
						setColor(colors.closed)
						v.Pole.FakeSensor.Alarm:Stop()
						table.remove(triggeredGates, table.find(triggeredGates, v))
						if #triggeredGates < 1 then
							triggered = false
						end
					end)
				end
			elseif v.Name == "Left" then
				local Hinge = v.Gate.Hinge.HingeConstraint
				Hinge.AngularResponsiveness = (Hinge.TargetAngle < 0 and not triggered) and math.huge or 10
				if Hinge.CurrentAngle > 7.5 and not debounce and not table.find(triggeredGates, v) then
					triggered = true
					table.insert(triggeredGates, v)
					v.Pole.FakeSensor.Alarm:Play()
					setColor(colors.alarm)
					Hinge.AngularResponsiveness = math.huge
					Hinge.TargetAngle = Hinge.CurrentAngle
					task.delay(1, function()
						Hinge.TargetAngle = Hinge.CurrentAngle / 2
						task.wait(1)
						Hinge.TargetAngle = 0
						task.wait(1)
						setColor(colors.closed)
						v.Pole.FakeSensor.Alarm:Stop()
						table.remove(triggeredGates, table.find(triggeredGates, v))
						if #triggeredGates < 1 then
							triggered = false

						end
					end)

				end
			end
		end
		task.wait(1)
	end
end
