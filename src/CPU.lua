-- Default CPU code:

local CPU_CALL = {}

-- [[ CPU Data Structures ]]

local Stack = {Space = {}, Index = 0}

function Stack:New(obj)
	obj = obj or {}
	setmetatable(obj, self)
	return obj	
end

function Stack:Push(data)
	self.Index = self.Index + 1
	self.Space[self.Index] = data
end

function Stack:Pop()
	local result = self.Space[self.Index]
	self.Space.remove(self.Index)
	return result
end

-- [[ Processor Registers ]]
CPU_CALL.REGISTERS = {}

-- //  Internal Registers
CPU_CALL.REGISTERS.INTERNAL_REGISTERS = {}

CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR = {} --| Instruction Register
CPU_CALL.REGISTERS.INTERNAL_REGISTERS.MBR = {} --| RAM Fetching Register
CPU_CALL.REGISTERS.INTERNAL_REGISTERS.MAR = {} --| RAM Fetching Address Register

-- // UA Registers
CPU_CALL.REGISTERS.USER_REGISTERS = {}

CPU_CALL.REGISTERS.USER_REGISTERS.D1 = {} -- [
CPU_CALL.REGISTERS.USER_REGISTERS.D2 = {} --	Data Registers
CPU_CALL.REGISTERS.USER_REGISTERS.D3 = {} --     Multi-Purpose
CPU_CALL.REGISTERS.USER_REGISTERS.D4 = {} --                    ]

CPU_CALL.REGISTERS.USER_REGISTERS.STATUS_FLAG = 1 --| CPU State Flag
CPU_CALL.REGISTERS.USER_REGISTERS.OFFSET_REGISTER_CURRENT = 0 --| Current Memory Segment Offset
CPU_CALL.REGISTERS.USER_REGISTERS.LATEST_COMPARE = 0 --| latest CMP operation result

-- [[ CPU Stack ]]
CPU_CALL.STACK = Stack.New(nil)

-- [[ Machine Code Processing ]]

CPU_CALL.Core = {ExecutionLabelTable = {}}

function CPU_CALL.Core:New(obj)
	obj = obj or {}
	setmetatable(obj, self)
	return obj
end

function CPU_CALL.SendSignal(data)
	--TODO signals
end

function CPU_CALL:Interrupt(interrupt_code)
	local intr_code = tonumber(interrupt_code)
	if intr_code then
		if intr_code == 1 then -- put at cursor
			CPU_CALL:SendSignal("HEADER: GPU PCAC".."CONTENT "..CPU_CALL.REGISTERS.USER_REGISTERS.D4)
		elseif intr_code == 2 then -- get char at cursor, put to D4
			CPU_CALL:SendSignal("HEADER: GPU GCAC".."CONTENT "..CPU_CALL.REGISTERS.USER_REGISTERS.D4)
		elseif intr_code == 3 then -- move to HDD sector
			CPU_CALL:SendSignal("HEADER: DRIVE MTS".."CONTENT "..CPU_CALL.REGISTERS.USER_REGISTERS.D4)
		elseif intr_code == 4 then -- move to HDD line of current sector
			CPU_CALL:SendSignal("HEADER: DRIVE MTL".."CONTENT "..CPU_CALL.REGISTERS.USER_REGISTERS.D4)
		elseif intr_code == 5 then -- write to HDD
			CPU_CALL:SendSignal("HEADER: DRIVE WRD".."CONTENT "..CPU_CALL.REGISTERS.USER_REGISTERS.D4)
		elseif intr_code == 6 then -- get at HDD
			CPU_CALL:SendSignal("HEADER: DRIVE GAP".."CONTENT "..CPU_CALL.REGISTERS.USER_REGISTERS.D4)
		end
	end
end

function CPU_CALL.Core:Execute(Data) -- Execute machine code of BPSS2 standard
	CPU_CALL.REGISTERS.USER_REGISTERS.STATUS_FLAG = 2 -- Code execution status flag
	
	local data_tokens = {}
	
	
	
	for token in Data:gmatch("%w+") do table.insert(data_tokens, token) end  -- Split the code in tokens
	
	
	
	local token_index={}
	for k,v in pairs(data_tokens) do
		token_index[v]=k
	end
	
	CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = 1
	
	while true do
		
		if CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] > 2 then
			if data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]] == "halt" then
				return true
			elseif data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]] == "label" then
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
				-- Set ExecutionLabelTable[label_name] = first_instruction_ir_index
				self.ExecutionLabelTable[data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
			elseif data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]] == "set" then
				-- Getting right UA Register
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
				local register_name = data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]
				
				-- Getting value
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
				local value = 0
				if not tonumber(data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]) then
					local register_name_2 = data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]
					if register_name_2 == "d1" or register_name_2 == "D1" then
						value = CPU_CALL.REGISTERS.USER_REGISTERS.D1[0]
					elseif register_name_2 == "d2" or register_name_2 == "D2" then
						value = CPU_CALL.REGISTERS.USER_REGISTERS.D1[0]
					elseif register_name_2 == "d3" or register_name_2 == "D3" then
						value = CPU_CALL.REGISTERS.USER_REGISTERS.D1[0]
					elseif register_name_2 == "d4" or register_name_2 == "D4" then
						value = CPU_CALL.REGISTERS.USER_REGISTERS.D1[0]
					end
				else
					value = tonumber(data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]])
				end
				
				-- Operation
				if register_name == "d1" or register_name == "D1" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D1[0] = value
				elseif register_name == "d2" or register_name == "D2" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D2[0] = value
				elseif register_name == "d3" or register_name == "D3" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D3[0] = value
				elseif register_name == "d4" or register_name == "D4" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D4[0] = value
				end
				
			elseif data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]] == "sub" then
				-- Getting right UA Register
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
				local register_name = data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]

				-- Getting value
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
				local value = tonumber(data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]])

				-- Operation
				if register_name == "d1" or register_name == "D1" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D1[0] = CPU_CALL.REGISTERS.USER_REGISTERS.D1[0] - value
				elseif register_name == "d2" or register_name == "D2" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D2[0] = CPU_CALL.REGISTERS.USER_REGISTERS.D2[0] - value
				elseif register_name == "d3" or register_name == "D3" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D3[0] = CPU_CALL.REGISTERS.USER_REGISTERS.D3[0] - value
				elseif register_name == "d4" or register_name == "D4" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D4[0] = CPU_CALL.REGISTERS.USER_REGISTERS.D4[0] - value
				end
				
			elseif data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]] == "add" then
				
				-- Getting right UA Register
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
				local register_name = data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]

				-- Getting value
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
				local value = tonumber(data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]])

				-- Operation
				if register_name == "d1" or register_name == "D1" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D1[0] = CPU_CALL.REGISTERS.USER_REGISTERS.D1[0] + value
				elseif register_name == "d2" or register_name == "D2" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D2[0] = CPU_CALL.REGISTERS.USER_REGISTERS.D2[0] + value
				elseif register_name == "d3" or register_name == "D3" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D3[0] = CPU_CALL.REGISTERS.USER_REGISTERS.D3[0] + value
				elseif register_name == "d4" or register_name == "D4" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D4[0] = CPU_CALL.REGISTERS.USER_REGISTERS.D4[0] + value
				end
			elseif data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]] == "push" then
				-- Pushing to the stack
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
				CPU_CALL.STACK:Push(data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]])
			elseif data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]] == "get" then
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
				local register_name = data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]
				-- Get to value
				if register_name == "d1" or register_name == "D1" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D1[0] = CPU_CALL.STACK:Pop()
				elseif register_name == "d2" or register_name == "D2" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D2[0] = CPU_CALL.STACK:Pop()
				elseif register_name == "d3" or register_name == "D3" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D3[0] = CPU_CALL.STACK:Pop()
				elseif register_name == "d4" or register_name == "D4" then
					CPU_CALL.REGISTERS.USER_REGISTERS.D4[0] = CPU_CALL.STACK:Pop()
				end
			elseif data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]] == "jmp" then
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
				local label_name = data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]
				local index = 0
				for k,v in pairs(data_tokens) do
					if v == label_name and k ~= CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] then
						index = k
					end
				end
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = index
			elseif data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]] == "cmp" then
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
				
				local first = 0
				local second = 0
				
				if not tonumber(data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]) then
					local register_name = data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]
				
					if register_name == "d1" or register_name == "D1" then
						first = CPU_CALL.REGISTERS.USER_REGISTERS.D1[0]
					elseif register_name == "d2" or register_name == "D2" then
						first = CPU_CALL.REGISTERS.USER_REGISTERS.D2[0]
					elseif register_name == "d3" or register_name == "D3" then
						first = CPU_CALL.REGISTERS.USER_REGISTERS.D3[0]
					elseif register_name == "d4" or register_name == "D4" then
						first = CPU_CALL.REGISTERS.USER_REGISTERS.D4[0]
					else
						first = data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]
					end
				end
				
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
				
				if not tonumber(data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]) then
					local register_name = data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]

					if register_name == "d1" or register_name == "D1" then
						second = CPU_CALL.REGISTERS.USER_REGISTERS.D1[0]
					elseif register_name == "d2" or register_name == "D2" then
						second = CPU_CALL.REGISTERS.USER_REGISTERS.D2[0]
					elseif register_name == "d3" or register_name == "D3" then
						second = CPU_CALL.REGISTERS.USER_REGISTERS.D3[0]
					elseif register_name == "d4" or register_name == "D4" then
						second = CPU_CALL.REGISTERS.USER_REGISTERS.D4[0]
					else
						second = data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]
					end
				end
				
				if first > second then CPU_CALL.REGISTERS.USER_REGISTERS.LATEST_COMPARE = 1 else CPU_CALL.REGISTERS.USER_REGISTERS.LATEST_COMPARE = 0 end
				
			elseif data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]] == "jg" then
				if CPU_CALL.REGISTERS.USER_REGISTERS.LATEST_COMPARE == 1 then
					CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
					local label_name = data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]
					local index = 0
					for k,v in pairs(data_tokens) do
						if v == label_name and k ~= CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] then
							index = k
						end
					end
					CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = index
				end
				
			elseif data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]] == "jl" then
				if CPU_CALL.REGISTERS.USER_REGISTERS.LATEST_COMPARE == 0 then
					CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
					local label_name = data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]]
					local index = 0
					for k,v in pairs(data_tokens) do
						if v == label_name and k ~= CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] then
							index = k
						end
					end
				end
			elseif data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]] == "intr" then
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
				local interrupt = tonumber(data_tokens[CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0]])
				if interrupt == 0 or interrupt then
					if interrupt == 0 then
						return true
					else
						CPU_CALL:Interrupt(interrupt)
					end
				else
					return false
				end
			end
		else
			if not (data_tokens[1] == "standard" and data_tokens[2] == "bpsa2") then
				return false -- Not BPSS2 standard! Halt the execution.
			else
				CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = 2
			end
		end
		
		
		CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] + 1
	end
	CPU_CALL.REGISTERS.INTERNAL_REGISTERS.IR[0] = 0
end


return CPU_CALL
