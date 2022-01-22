#!/usr/bin/env python3
#######################################
# IMPORTS
#######################################

from audioop import add
from cProfile import label
import re
import argparse
import sys
from token import OP

from dlx_constants import *
from dlx_utilities import *


#######################################
# POSITION
#######################################

class Position:
	def __init__(self, idx, ln, col, fn, ftxt):
		self.idx = idx
		self.ln = ln
		self.col = col
		self.fn = fn
		self.ftxt = ftxt

	def advance(self, current_char=None):
		self.idx += 1
		self.col += 1

		if current_char == '\n':
			self.ln += 1
			self.col = 0

		return self

	def copy(self):
		return Position(self.idx, self.ln, self.col, self.fn, self.ftxt)

#######################################
# TOKENS
#######################################


TT_INT = 'INT'
TT_SEGMENT = 'SEGMENT'
TT_INSTRUCTION = 'INSTRUCTION'
TT_REGISTER = 'REGISTER'
TT_LABEL = 'LABEL'
TT_VARIABLE = 'VARIABLE'
TT_INVALID = 'INVALID'
TT_EOF = 'EOF'

class Token:
	def __init__(self, type_, value=None, pos_start=None, pos_end=None):
		self.type = type_
		self.value = value

		if pos_start:
			self.pos_start = pos_start.copy()
			self.pos_end = pos_start.copy()
			self.pos_end.advance()

		if pos_end:
			self.pos_end = pos_end.copy()

	def matches(self, type_, value):
		return self.type == type_ and self.value == value

	def __repr__(self):
		if self.value != None:
			return f'{self.type}:{self.value}'
		return f'{self.type}'

#######################################
# LEXER
#######################################


class Lexer:
	def __init__(self, fn, text):
		self.in_data_segment = False
		self.variable_names = []
		self.fn = fn
		self.text = text
		self.pos = Position(-1, 0, -1, fn, text)
		self.current_char = None
		self.advance()

	def advance(self):
		self.pos.advance(self.current_char)
		self.current_char = self.text[self.pos.idx] if self.pos.idx < len(
			self.text) else None

	def make_tokens(self):
		tokens = []

		while self.current_char != None:
			if self.current_char == ';':  # skip comment lines
				while self.current_char != '\n':
					self.advance()
			elif self.current_char in ' (),\t\n':
				self.advance()
			elif self.current_char == '.':
				self.advance()
				tokens.append(self.make_segment())
			elif self.current_char == 'R':
				pos_start = self.pos.copy()
				reg_tok = self.make_register()
				if reg_tok.type:
					tokens.append(reg_tok)
				else:
					return [], InvalidRegisterError(pos_start, self.pos, reg_tok.value)
			elif self.current_char in LETTERS:
				tokens.append(self.make_identifier())
			elif self.current_char in DIGITS or self.current_char == '-':
				tokens.append(self.make_number())
			else:
				pos_start = self.pos.copy()
				char = self.current_char
				self.advance()
				return [], IllegalCharError(pos_start, self.pos, "'" + char + "'")

		tokens.append(Token(TT_EOF, pos_start=self.pos))

		return tokens, None

	def make_number(self):
		num_str = self.current_char
		pos_start = self.pos.copy()
		self.advance()

		while self.current_char != None and self.current_char in DIGITS:
			num_str += self.current_char
			self.advance()

		return Token(TT_INT, int(num_str), pos_start, self.pos)

	def make_segment(self):
		segment_name = ''
		pos_start = self.pos.copy()

		while self.current_char != None and self.current_char in LETTERS:
			segment_name += self.current_char
			self.advance()

		if segment_name == DATA_SEGMENT:
			self.in_data_segment = True
		else:
			self.in_data_segment = False

		tok_type = TT_SEGMENT
		return Token(tok_type, segment_name, pos_start, self.pos)

	def make_identifier(self):
		id_str = ''
		pos_start = self.pos.copy()

		while self.current_char != None and self.current_char in LABEL_CHARS:
			id_str += self.current_char
			self.advance()

		tok_type = TT_LABEL
		if id_str in INSTRUCTIONS:
			tok_type = TT_INSTRUCTION
		elif self.in_data_segment:
			tok_type = TT_VARIABLE
			self.variable_names.append(id_str)
		elif id_str in self.variable_names:
			tok_type = TT_VARIABLE

		return Token(tok_type, id_str, pos_start, self.pos)

	def make_register(self):
		reg_str = ''
		pos_start = self.pos.copy()

		while self.current_char != None and self.current_char in LETTERS_DIGITS:
			reg_str += self.current_char
			self.advance()

		tok_type = None

		if reg_str in REGISTERS:
			tok_type = TT_REGISTER

		return Token(tok_type, reg_str, pos_start, self.pos)

#######################################
# PARSER
#######################################


class Parser:
	def __init__(self, tokens):
		self.tokens = tokens
		self.parsed_data_tokens = []
		self.parsed_text_tokens = []
		self.tok_idx = -1
		self.advance()

	def advance(self, ):
		self.tok_idx += 1
		if self.tok_idx < len(self.tokens):
			self.current_tok = self.tokens[self.tok_idx]
		return self.current_tok

	def parse(self):
		error = None

		# parse data section
		if self.current_tok.value == DATA_SEGMENT:
			self.advance()
			while self.current_tok.type != TT_EOF and not error:
				if self.current_tok.type == TT_SEGMENT:
					if self.current_tok.value == TEXT_SEGMENT:
						self.advance()
						break
					else:
						error = UnexpectedSegmentError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
				else:
					error = self.parse_var()
		else:
			error = NoDataSectionFoundError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)

		# parse text section
		while self.current_tok.type != TT_EOF and not error:
			if self.current_tok.value in REGISTER_OPS:
				error = self.regs_op()
			elif self.current_tok.value in IMMEDIATE_OPS:
				error = self.imm_op()
			elif self.current_tok.value in JUMP_OPS:
				error = self.jump_op()
			elif self.current_tok.value in BRANCH_OPS:
				error = self.branch_op()
			elif self.current_tok.value in MEMORY_OPS:
				error = self.memory_op()
			elif self.current_tok.value in NO_OPS:
				error = self.no_op()
			elif self.current_tok.type == TT_LABEL and not self.current_tok.value.isupper():
				self.parsed_text_tokens.append([self.current_tok])
				self.advance()
			else:
				error = InvalidInstructionError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)

		return error
	
	def parse_var(self):
		variable = []
		
		if self.current_tok.type == TT_VARIABLE:
			variable.append(self.current_tok)
			self.advance()
		else:
			return ExpectedVariableError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
		
		size = 0
		if self.current_tok.type == TT_INT:
			size = self.current_tok.value
			self.advance()
		else:
			return ExpectedVariableSizeError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
		
		for i in range(size):
			if self.current_tok.type == TT_INT:
				variable.append(self.current_tok)
				self.advance()
			else:
				return UnexpectedEndOfArrayError(self.current_tok.pos_start, self.current_tok.pos_end, size, i, self.current_tok.value)
	
		self.parsed_data_tokens.append(variable)
		return None

	def regs_op(self):
		inst = []
		
		inst.append(self.current_tok)
		self.advance()
		
		for i in range(3):
			if self.current_tok.type == TT_REGISTER:
				inst.append(self.current_tok)
				self.advance()
			else:
				return ExpectedRegisterError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
		self.parsed_text_tokens.append(inst)
		return None
	
	def imm_op(self):
		inst = []
		
		inst.append(self.current_tok)
		self.advance()
		
		for i in range(2):
			if self.current_tok.type == TT_REGISTER:
				inst.append(self.current_tok)
				self.advance()
			else:
				return ExpectedRegisterError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
		
		if self.current_tok.type == TT_INT:
			if self.current_tok.value < 0:
				if int(self.current_tok.value) >= IMM_MIN_SIGNED:
					inst.append(self.current_tok)
				else:
					return InvalidLoadValueError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
			else:
				if int(self.current_tok.value) <= IMM_MAX_UNSIGNED:
					inst.append(self.current_tok)
				else:
					return InvalidLoadValueError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
		else:
			return ExpectedIntegerError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
		
		self.advance()
		self.parsed_text_tokens.append(inst)
		return None
	
	def jump_op(self):
		inst = []
		
		inst.append(self.current_tok)
		self.advance()

		if self.current_tok.type == TT_REGISTER:
			if self.current_tok.value in REGISTERS:
					inst.append(self.current_tok)
					self.advance()
			else:
				return InvalidRegisterError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)      
		elif self.current_tok.type == TT_LABEL:
			inst.append(self.current_tok)
			self.advance()
		else:
			return InvalidJumpOperandError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
		
		self.parsed_text_tokens.append(inst)
		return None
	
	def branch_op(self):
		inst = []
		
		inst.append(self.current_tok)
		self.advance()  

		if self.current_tok.type == TT_REGISTER:
				inst.append(self.current_tok)
				self.advance()
		else:
			return ExpectedRegisterError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
		
		if self.current_tok.type == TT_LABEL:
			inst.append(self.current_tok)
			self.advance()
		else:
			return ExpectedLabelError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
		
		self.parsed_text_tokens.append(inst)
		return None
	
	def memory_op(self):
		inst = [] 
		
		inst.append(self.current_tok)
		
		if self.current_tok.value == 'SW':
			self.advance()
			if self.current_tok.type == TT_VARIABLE:
				inst.append(self.current_tok)
				self.advance()
			else:
				return ExpectedVariableError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
			if self.current_tok.type == TT_REGISTER:
				inst.append(self.current_tok)
				self.advance()
			else:
				return ExpectedRegisterError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
		else:
			self.advance()
			if self.current_tok.type == TT_REGISTER:
				inst.append(self.current_tok)
				self.advance()
			else:
				return ExpectedRegisterError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
			if self.current_tok.type == TT_VARIABLE:
				inst.append(self.current_tok)
				self.advance()
			else:
				return ExpectedVariableError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
		
		if self.current_tok.type == TT_REGISTER:
				inst.append(self.current_tok)
				self.advance()
		else:
			return ExpectedRegisterError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
		
		self.parsed_text_tokens.append(inst)
		return None
	
	def no_op(self):
		inst =[]
		
		inst.append(self.current_tok)
		self.advance()

		self.parsed_text_tokens.append(inst)
		return None

#######################################
# ASSEMBLER
#######################################

class Assembler():
	def __init__(self):
		self.variable_addrs = {}
		self.label_addrs = {}
	
	def resolve_label_addresses(self, code):
		address = 0
		for line in code:
			if line[0].type == TT_INSTRUCTION:
				address += 1
			else:
				label_name = line[0].value
				if label_name not in self.label_addrs:
					self.label_addrs[label_name] = address
				else:
					print("ERROR")
					return LabelRedeclarationError(line[0].pos_start, line[0].pos_end, label_name)
		
		for item in code:
			if item[0].type == TT_LABEL:
				code.remove(item)

		return None

	def build_data_mif(self, data):
		mif_text = MIF_PREAMBLE
		address = 0
		for array in data:
			var_name = array[0].value

			if var_name not in self.variable_addrs:
				self.variable_addrs[var_name] = address
			else:
				return None, VariableRedeclarationError(array[0].pos_start, array[0].pos_end, var_name)
			
			for index in range(1, len(array)):
				addr_str = format(address, 'X').zfill(ADDR_PAD_SIZE)
				value_str = format(array[index].value, 'X').zfill(WORD_PAD_SIZE)
				mif_text += f'{addr_str} : {value_str}; --{var_name}[{index-1}]\n'

				address += 1
		
		mif_text += MIF_EPILOGUE

		return mif_text, None

	def build_code_mif(self, code):
		error = None
		mif_text = MIF_PREAMBLE
		address = 0

		# find the addresses of all labels
		error = self.resolve_label_addresses(code)
		if error:
			return None, error

		#build the mif file
		for instruction in code:
			# get the each instruction
			inst_name = instruction[0].value
			addr_str = format(address, 'X').zfill(ADDR_PAD_SIZE)
			op_code = OP_CODES_DICT[inst_name]
			inst_str = format(op_code, 'X').zfill(WORD_PAD_SIZE)
			comment_str = '\t\t'

			# start at offset 1 these are the operands, offset 0 ins the instruction name
			for index in range(1, len(instruction)-1):
				comment_str += str(instruction[index].value) + ', '
			comment_str += str(instruction[-1].value) + '\n'
			
			mif_text += f'{addr_str} : {inst_str}; --{inst_name}' + comment_str

			address += 1
		
		mif_text += MIF_EPILOGUE

		return mif_text, None

		
#######################################
# RUN
#######################################


def run(fn, text):
	# Generate tokens
	lexer = Lexer(fn, text)
	tokens, error = lexer.make_tokens()
	if error:
		return None, None, error
	print(tokens)
	print('\n======\n')
	# Generate AST
	parser = Parser(tokens)
	error = parser.parse()
	if error: return None, None, error
	
	print('\nDATA SEGMENT')
	print(parser.parsed_data_tokens)
	print('\nTEXT SEGMENT')
	print(parser.parsed_text_tokens)

	# Generate mifs
	assembler = Assembler()

	data, error = assembler.build_data_mif(parser.parsed_data_tokens)
	if error: return None, None, error

	code, error = assembler.build_code_mif(parser.parsed_text_tokens)
	if error: return None, None, error

	return data, code, None


if __name__ == '__main__':

	datafile = None
	codefile = None

	if len(sys.argv) <= 1 or len(sys.argv) > 4 or len(sys.argv) == 3:
		sys.exit("Error: invalid command line entry")
	elif len(sys.argv) == 2:
		infile = sys.argv[1]
	else:
		infile  = sys.argv[1]
		datafile = sys.argv[2]
		codefile = sys.argv[3]
	

	with open(infile, 'r') as file:
		text = ''.join(file.readlines())
		data, code, error = run(infile, text)

		if error:
			print(error.as_string())
		else:
			if datafile:
				with open(datafile, 'w') as out:
					out.writelines(data)
			if codefile:
				with open(codefile, 'w') as out:
					out.writelines(code)
			else:
				print(data)
				print(code)
