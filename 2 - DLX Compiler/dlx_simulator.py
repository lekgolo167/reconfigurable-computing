import argparse
import ctypes
from datetime import datetime

def rshift(val, n):
	return (val % 0x100000000) >> n

class Instruction:
	def __init__(self, op_code=0, rd=0, rs1=0, rs2=0, imm=0, label=0, offset=0, base=0, r_destination=0, r_comp=0):
		self.op_code = op_code
		self.rd = rd
		self.rs1 = rs1
		self.rs2 = rs2
		self.imm = imm
		self.label = label
		self.offset = offset
		self.base = base
		self.r_destination = r_destination
		self.r_comp = r_comp
		self.branch_taken = 0
		self.branch_not_taken = 0
		self.timer_value = 0
		self.timer_date = datetime.now()

class NOP(Instruction):
	def execute(self, registers, memory, pc_counter):
		return pc_counter + 1

class LW(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.r_destination] = memory[self.base + registers[self.offset]]
		return pc_counter + 1

class SW(Instruction):
	def execute(self, registers, memory, pc_counter):
		memory[self.base + registers[self.offset]] = registers[self.r_destination]
		return pc_counter + 1

class ADD(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = registers[self.rs1] + registers[self.rs2]
		return pc_counter + 1

class ADDI(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = registers[self.rs1] + self.imm
		return pc_counter + 1

class ADDU(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = ctypes.c_ulong(registers[self.rs1] + registers[self.rs2]).value
		return pc_counter + 1

class ADDUI(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = ctypes.c_ulong(registers[self.rs1] + self.imm).value
		return pc_counter + 1

class SUB(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = registers[self.rs1] - registers[self.rs2]
		return pc_counter + 1

class SUBI(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = registers[self.rs1] - self.imm
		return pc_counter + 1

class SUBU(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = ctypes.c_ulong(registers[self.rs1] - registers[self.rs2]).value
		return pc_counter + 1

class SUBUI(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = ctypes.c_ulong(registers[self.rs1] - self.imm).value
		return pc_counter + 1

class AND(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = registers[self.rs1] & registers[self.rs2]
		return pc_counter + 1

class ANDI(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = registers[self.rs1] & self.imm
		return pc_counter + 1

class OR(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = registers[self.rs1] | registers[self.rs2]
		return pc_counter + 1

class ORI(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = registers[self.rs1] | self.imm
		return pc_counter + 1

class XOR(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = registers[self.rs1] ^ registers[self.rs2]
		return pc_counter + 1

class XORI(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = registers[self.rs1] ^ self.imm
		return pc_counter + 1

class SLL(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = (registers[self.rs1] << registers[self.rs2]) & 0xFFFFFFFF
		return pc_counter + 1

class SLLI(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = (registers[self.rs1] << self.imm) & 0xFFFFFFFF
		return pc_counter + 1

class SRL(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = rshift(registers[self.rs1], registers[self.rs2])
		return pc_counter + 1

class SRLI(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = rshift(registers[self.rs1], self.imm)
		return pc_counter + 1

class SRA(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = registers[self.rs1] >> registers[self.rs2]
		return pc_counter + 1

class SRAI(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[self.rd] = registers[self.rs1] >> self.imm
		return pc_counter + 1

class SLT(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.rs1] < registers[self.rs2]:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SLTI(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.rs1] < self.imm:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SLTU(Instruction):
	def execute(self, registers, memory, pc_counter):
		if ctypes.c_ulong(registers[self.rs1]).value < ctypes.c_ulong(registers[self.rs2]).value:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SLTUI(Instruction):
	def execute(self, registers, memory, pc_counter):
		if ctypes.c_ulong(registers[self.rs1]).value < ctypes.c_ulong(self.imm).value:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SGT(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.rs1] > registers[self.rs2]:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SGTI(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.rs1] > self.imm:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SGTU(Instruction):
	def execute(self, registers, memory, pc_counter):
		if ctypes.c_ulong(registers[self.rs1]).value > ctypes.c_ulong(registers[self.rs2]).value:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SGTUI(Instruction):
	def execute(self, registers, memory, pc_counter):
		if ctypes.c_ulong(registers[self.rs1]).value > ctypes.c_ulong(self.imm).value:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SLE(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.rs1] <= registers[self.rs2]:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SLEI(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.rs1] <= self.imm:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SLEU(Instruction):
	def execute(self, registers, memory, pc_counter):
		if ctypes.c_ulong(registers[self.rs1]).value <= ctypes.c_ulong(registers[self.rs2]).value:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SLEUI(Instruction):
	def execute(self, registers, memory, pc_counter):
		if ctypes.c_ulong(registers[self.rs1]).value <= ctypes.c_ulong(self.imm).value:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SGE(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.rs1] >= registers[self.rs2]:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SGEI(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.rs1] >= self.imm:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SGEU(Instruction):
	def execute(self, registers, memory, pc_counter):
		if ctypes.c_ulong(registers[self.rs1]).value >= ctypes.c_ulong(registers[self.rs2]).value:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SGEUI(Instruction):
	def execute(self, registers, memory, pc_counter):
		if ctypes.c_ulong(registers[self.rs1]).value >= ctypes.c_ulong(self.imm).value:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SEQ(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.rs1] == registers[self.rs2]:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SEQI(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.rs1] == self.imm:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SNE(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.rs1] != registers[self.rs2]:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class SNEI(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.rs1] != self.imm:
			registers[self.rd] = 1
		else:
			registers[self.rd] = 0
		return pc_counter + 1

class BEQZ(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.r_comp] == 0:
			self.branch_taken += 1
			return self.label
		else:
			self.branch_not_taken += 1
			return pc_counter + 1

class BNEZ(Instruction):
	def execute(self, registers, memory, pc_counter):
		if registers[self.r_comp] != 0:
			self.branch_taken += 1
			return self.label
		else:
			self.branch_not_taken += 1
			return pc_counter + 1

class J(Instruction):
	def execute(self, registers, memory, pc_counter):
		return self.label

class JR(Instruction):
	def execute(self, registers, memory, pc_counter):
		return registers[self.label]

class JAL(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[31] = pc_counter + 1
		return self.label

class JALR(Instruction):
	def execute(self, registers, memory, pc_counter):
		registers[31] = pc_counter + 1
		return registers[self.label]

class PCH(Instruction):
	def execute(self, registers, memory, pc_counter):
		print("PCH -> " + chr(registers[self.rs1] & 0xFF))
		return pc_counter + 1

class PD(Instruction):
	def execute(self, registers, memory, pc_counter):
		print("PD -> " + str(registers[self.rs1]))
		return pc_counter + 1

class PDU(Instruction):
	def execute(self, registers, memory, pc_counter):
		print("PDU -> " + str(ctypes.c_ulong(registers[self.rs1]).value))
		return pc_counter + 1

class GD(Instruction):
	def execute(self, registers, memory, pc_counter):
		x = input("GD -> ")
		registers[self.r_destination] = ctypes.c_long(int(x)).value
		return pc_counter + 1

class GDU(Instruction):
	def execute(self, registers, memory, pc_counter):
		x = input("GDU -> ")
		registers[self.r_destination] = ctypes.c_ulong(int(x)).value
		return pc_counter + 1

class TR(Instruction):
	def execute(self, register, memory, pc_counter):
		self.timer_value = 0
		self.timer_date = None
		print("TR -> Timer reset");
		return pc_counter + 1

class TGO(Instruction):
	def execute(self, register, memory, pc_counter):
		if self.timer_date is None:
			self.timer_date = datetime.now()
		print("TGO -> timer started");
		return pc_counter + 1

class TSP(Instruction):
	def execute(self, register, memory, pc_counter):
		timeD = (datetime.now() - self.timer_date)
		self.timer_value += (timeD.seconds * 1000000)  + timeD.microseconds
		print(f"TSP -> Timer stopped: {self.timer_value}");
		return pc_counter + 1

inst_dict = {
	0X0:NOP,
	0X1:LW,
	0X2:SW,
	0X3:ADD,
	0X4:ADDI,
	0X5:ADDU,
	0X6:ADDUI,
	0X7:SUB,
	0X8:SUBI,
	0X9:SUBU,
	0XA:SUBUI,
	0XB:AND,
	0XC:ANDI,
	0XD:OR,
	0XE:ORI,
	0XF:XOR,
	0X10:XORI,
	0X11:SLL,
	0X12:SLLI,
	0X13:SRL,
	0X14:SRLI,
	0X15:SRA,
	0X16:SRAI,
	0X17:SLT,
	0X18:SLTI,
	0X19:SLTU,
	0X1A:SLTUI,
	0X1B:SGT,
	0X1C:SGTI,
	0X1D:SGTU,
	0X1E:SGTUI,
	0X1F:SLE,
	0X20:SLEI,
	0X21:SLEU,
	0X22:SLEUI,
	0X23:SGE,
	0X24:SGEI,
	0X25:SGEU,
	0X26:SGEUI,
	0X27:SEQ,
	0X28:SEQI,
	0X29:SNE,
	0X2A:SNEI,
	0X2B:BEQZ,
	0X2C:BNEZ,
	0X2D:J,
	0X2E:JR,
	0X2F:JAL,
	0X30:JALR,
	0x31:PCH,
	0x32:PD,
	0x33:PDU,
	0x34:GD,
	0x35:GDU,
	0x36:TR,
	0x37:TGO,
	0x38:TSP
}

class DlxSimulator:
	def __init__(self, code_name, data_name, exit_point, max_iters, reg_limit, step_through, branch_stats, info):
		self.pc_counter = 0
		self.instruction_memory = []
		self.data_memory = []
		self.registers = { reg:0 for reg in range(32)}
		self.exit_addr = exit_point
		self.max_iterations = max_iters
		self.reg_limit = reg_limit if reg_limit < 32 else 31
		self.step_mode = step_through
		self.branch_stats = branch_stats
		self.info = info

		self.parse_data_mif(data_name)
		self.parse_code_mif(code_name)

	def parse_data_mif(self, fname):
		with open(fname, 'r') as infile:
			lines = infile.readlines()
			for line in lines:
				start = line.find(':')
				end = line.find(';')
				if start < 0:
					continue

				var = int(line[start+1:end], 16)
				self.data_memory.append(var)

	def parse_code_mif(self, fname):
		with open(fname, 'r') as infile:
			lines = infile.readlines()
			for line in lines:
				start = line.find(':')
				end = line.find(';')
				if start < 0:
					continue

				inst = int(line[start+1:end], 16)
				binary = format(inst, 'b').zfill(32)
				op_code = int(binary[0:6], 2)
				rd = int(binary[6:11], 2)
				rs1 = int(binary[11:16], 2)
				rs2 = int(binary[16:21], 2)
				imm = int(binary[16:32], 2)
				label = int(binary[11:32], 2)

				obj = inst_dict[op_code](rd=rd, rs1=rs1, rs2=rs2, imm=imm, label=label, offset=rs1, base=imm, r_destination=rd, r_comp=rd)
				self.instruction_memory.append(obj)

	def run_program(self):
		pc_counter = 0
		iterations = 0
		while iterations < self.max_iterations:
			inst = self.instruction_memory[pc_counter]
			pc_next_counter = inst.execute(self.registers, self.data_memory, pc_counter)
			if pc_counter == self.exit_addr:
				break
			iterations += 1
			if self.step_mode:
				self.show_results()
				x = input(f"[{hex(pc_counter)}] -> [{hex(pc_next_counter)}] Continue?")
			pc_counter = pc_next_counter
		
		if iterations == self.max_iterations:
			print('Max loop iterations reached!')
		elif self.info:
			self.show_results()
			print(f'Finished in {iterations} iterations')

		if self.branch_stats:
			self.branch_analysis()

	def show_results(self):
		print('=== Memory Contents ===')
		addr = 0
		for data in self.data_memory:
			print(f'{hex(addr)} : {data}')
			addr += 1

		print('\n=== Register Contents ===')
		for reg in range(self.reg_limit):
			print(f'R{reg}:{self.registers[reg]}')
		print(f'R{31}:{self.registers[31]}')

	def branch_analysis(self):
		addr = 0
		for inst in self.instruction_memory:
			if isinstance(inst,BEQZ) or isinstance(inst, BNEZ):
				print(f'0x{format(addr, "X").zfill(3)} - Taken: {inst.branch_taken}, Not Taken: {inst.branch_not_taken}')
			addr += 1

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('--code', '-c', nargs='?', required=True,
						help='The code .mif file ')
	parser.add_argument('--data', '-d', nargs='?', required=True,
						help='The data .mif file')
	parser.add_argument('--exit', '-e', nargs='?', required=True,
						help='The exit/done address of the program in hex')
	parser.add_argument('--max', '-m', nargs='?', default=1000,
						help='Max iterations through the program loop')
	parser.add_argument('--reg', '-r', nargs='?', default=32,
						help='Limit the number of registers shown from 0-r')
	parser.add_argument('--step', '-s', action='store_true', default=False,
						help='Enables stepping through the program')
	parser.add_argument('--branch', '-b', action='store_true', default=False,
						help='Enables branch analysis at the end of the program')
	parser.add_argument('--info', '-i', action='store_true', default=False,
						help='Enables printing of how many cycles the program took and final register and memory states')
	argument = parser.parse_args()

	code_file = argument.code
	data_file = argument.data
	exit_point = int(argument.exit, 16)
	max_iters = int(argument.max)
	reg_limit = int(argument.reg)
	step_through = bool(argument.step)
	branch_stats = bool(argument.branch)
	info = bool(argument.info)

	sim = DlxSimulator(code_file, data_file, exit_point, max_iters, reg_limit, step_through, branch_stats, info)
	sim.run_program()