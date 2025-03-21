local mod = ISAACREBALANCED
local teleportRNG = RNG()
Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_TELEPORT).Quality = 1

--thank you pixel!!!

-- Level grid functions
function mod:RoomIdxToVector(idx)
	return Vector(idx % 13, math.floor(idx / 13))
end

function mod:RoomVectorToIdx(vector)
	return vector.X + (vector.Y * 13)
end



-- Override Teleporter functionality
function mod:useTeleporter(type, rng, player, flags, slot, customdata)
	local level = Game():GetLevel()
	local room = Game():GetRoom()

	-- Get direction
	local playerDir = player:GetMovementDirection()
	local direction = Vector(0, 0)

	if playerDir == Direction.LEFT then
		direction.X = -1
	elseif playerDir == Direction.UP then
		direction.Y = -1
	elseif playerDir == Direction.RIGHT then
		direction.X = 1
	elseif playerDir == Direction.DOWN then
		direction.Y = 1
	end


	-- Get which part of the room to count from
	local currentIdx = level:GetCurrentRoomDesc().GridIndex
	local shape = room:GetRoomShape()

	-- Big rooms
	if shape >= 4 then
		local actualCenterPos = room:GetCenterPos()
		-- For L shaped rooms
		if shape >= 9 then
			actualCenterPos = Vector(580, 420) -- Where the corner is
		end

		-- Count from the bottom half
		if (shape == RoomShape.ROOMSHAPE_1x2 or shape == RoomShape.ROOMSHAPE_IIV or shape >= 8)
		and player.Position.Y > actualCenterPos.Y then
			currentIdx = currentIdx + 13
		end

		-- Count from the right side
		if shape >= 6 and player.Position.X > actualCenterPos.X then
			currentIdx = currentIdx + 1
		end
	end


	-- Get list of possible rooms
	local possibleRooms = {}

	for i = 1, 4 do
		local testIdx = mod:RoomIdxToVector(currentIdx) + (direction * i)

		-- Clamp index within floor bounds
		local testIdx_X = math.min(12, math.max(0, testIdx.X) )
		local testIdx_Y = math.min(12, math.max(0, testIdx.Y) )

		testIdx = Vector(testIdx_X, testIdx_Y)
		testIdx = mod:RoomVectorToIdx(testIdx)


		-- Ignore invalid rooms and indexes pointing to the current room
		if level:GetRoomByIdx(testIdx, -1).Data ~= nil and level:GetRoomByIdx(testIdx, -1).ListIndex ~= level:GetCurrentRoomDesc().ListIndex  and level:GetRoomByIdx(testIdx, -1).Data.Type ~= RoomType.ROOM_ULTRASECRET then
			-- Only put it in the list if it's not already in it
			local alreadyInList = false
			for j, entry in pairs (possibleRooms) do
				if testIdx == entry then
					alreadyInList = true
					break
				end
			end

			if alreadyInList == false then
				table.insert(possibleRooms, testIdx)

				-- Uncleared rooms are more likely to be chosen
				if level:GetRoomByIdx(testIdx, -1).Clear == false then
					table.insert(possibleRooms, testIdx)
				end
			end
		end
	end


	-- Choose a room if there are valid choices
	if #possibleRooms > 0 then
		local choice = teleportRNG:RandomInt(#possibleRooms) + 1
		local chosenRoom = possibleRooms[choice]

		Game():StartRoomTransition(chosenRoom, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, -1)
		return true

	-- Use default functionality if there are no valid choices
	else
		SFXManager():Play(SoundEffect.SOUND_EDEN_GLITCH, 0.9)
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, mod.useTeleporter, CollectibleType.COLLECTIBLE_TELEPORT)