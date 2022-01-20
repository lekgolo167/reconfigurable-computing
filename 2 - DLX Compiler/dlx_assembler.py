#!/usr/bin/env python3
#######################################
# IMPORTS
#######################################

import re
import argparse

from dlx_constants import *
from dlx_utilities import *

REG_DICT = {'R0':'00', 'R1':'01', 'R2':'10', 'R3':'11'}
INST_DICT = {'LOAD':'00XXYYYY', 'STORE':'01XX0000', 'MOVE':'10XXYY00', 'ADD':'11XXYY00', 'SUB':'11XXYY01', 'AND':'11XXYY10', 'NOT':'11XXYY11'}

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

UNI_OPS = [
	'NOT',
	'STORE',
]

BIN_OPS = [
	'MOVE',
	'ADD',
	'SUB',
	'AND',
]

DATA_OPS = [
	'LOAD'
]

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
			if self.current_char == ';': # skip comment lines
				while self.current_char != '\n':
					self.advance()
			elif self.current_char in ' (),\t\n':
				self.advance()
			elif self.current_char == '.':
				self.advance()
				tokens.append(self.make_segment())
			elif self.current_char == 'R':
				tokens.append(self.make_register())
			elif self.current_char in LETTERS:
				tokens.append(self.make_identifier())
			elif self.current_char in DIGITS:
				tokens.append(self.make_number())
			else:
				pos_start = self.pos.copy()
				char = self.current_char
				self.advance()
				return [], IllegalCharError(pos_start, self.pos, "'" + char + "'")

		tokens.append(Token(TT_EOF, pos_start=self.pos))

		return tokens, None

	def make_number(self):
		num_str = ''
		pos_start = self.pos.copy()

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

		tok_type = TT_REGISTER
		return Token(tok_type, reg_str, pos_start, self.pos)

#######################################
# PARSER
#######################################

class Parser:
	def __init__(self, tokens):
		self.tokens = tokens
		self.parsed_tokens = []
		self.tok_idx = -1
		self.advance()

	def advance(self, ):
		self.tok_idx += 1
		if self.tok_idx < len(self.tokens):
			self.current_tok = self.tokens[self.tok_idx]
		return self.current_tok

	def parse(self):
		error = None

		while self.current_tok.type != TT_EOF and not error:

			if self.current_tok.value in UNI_OPS:
				error = self.bin_op(1, False)
			elif self.current_tok.value in BIN_OPS:
				error = self.bin_op(2, False)
			elif self.current_tok.value in DATA_OPS:
				error = self.bin_op(1, True)
			else:
				error = InvalidInstructionError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)

		return error

	def bin_op(self, num, load_op):
		inst = []

		inst.append(self.current_tok)
		self.advance()
		
		for x in range(num):
			if re.fullmatch(r'R\d', self.current_tok.value):
				if self.current_tok.value in REGISTERS:
					inst.append(self.current_tok)
					self.advance()
				else:
					print(1)
					return InvalidRegisterError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
			else:
				print(2)
				return InvalidRegisterError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)
		
		if load_op:
			if self.current_tok.value >= 0 and self.current_tok.value <= 15:
				inst.append(self.current_tok)
				self.advance()
			else:
				return InvalidLoadValueError(self.current_tok.pos_start, self.current_tok.pos_end, self.current_tok.value)

		self.parsed_tokens.append(inst)

		return None

#######################################
# ASSEMBLER
#######################################

class Assembler():
	def __init__(self):
		self.binary_strings = []
	
	def build_binary(self, ast):
		inst_str = ''
		for expr in ast:
			inst_str = INST_DICT[expr[0].value]

			if expr[0].value == 'LOAD':
				inst_str = inst_str.replace('XX', REG_DICT[expr[1].value])
				inst_str = inst_str.replace('YYYY', bin(expr[2].value)[2:].zfill(4))
				inst_str += '; // ' + expr[0].value + ' ' + expr[1].value + ' ' + str(expr[2].value)
			elif expr[0].value in ['NOT', 'STORE']:
				inst_str = inst_str.replace('XX', REG_DICT[expr[1].value])
				inst_str += '; // ' + expr[0].value + ' ' + expr[1].value
			else:
				inst_str = inst_str.replace('XX', REG_DICT[expr[1].value])
				inst_str = inst_str.replace('YY', REG_DICT[expr[2].value])
				inst_str += '; // ' + expr[0].value + ' ' + expr[1].value + ' ' + expr[2].value

			self.binary_strings.append(inst_str)

	def write_verilog(self):
		verilog = f'limit = {len(self.binary_strings)};\ncase(count)\n'
		count = 1
		for instruction in self.binary_strings:
			verilog += f"\t{count}: inst = 8'b{instruction}\n\n"
			count += 1

		verilog += "\tdefault: inst = 8'b00000000;\nendcase"

		return verilog

		
#######################################
# RUN
#######################################

def run(fn, text):
	# Generate tokens
	lexer = Lexer(fn, text)
	tokens, error = lexer.make_tokens()
	if error:
		return None, error

	# temporary delete this line after lexer works
	return tokens, None

	# Generate AST
	parser = Parser(tokens)
	error = parser.parse()
	if error: return None, error
	
	# Generate verilog
	assembler = Assembler()
	assembler.build_binary(parser.parsed_tokens)
	v = assembler.write_verilog()
	return v, None


if __name__ == '__main__':

	parser = argparse.ArgumentParser()
	
	parser.add_argument('-i', type=str, required=True, help="file input name for assembly code")
	parser.add_argument('-o', type=str, required=False, help="file output name for verilog code")
	args = parser.parse_args()

	with open(args.i, 'r') as file:
		text = ''.join(file.readlines())
		result, error = run(args.i, text)

		if error:
			print(error.as_string())
		else:
			if args.o:
				with open(args.o, 'w') as out:
					out.writelines(result)
			else:
				print(result)
