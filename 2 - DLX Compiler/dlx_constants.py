import string

#######################################
# CONSTANTS
#######################################

DIGITS = '0123456789'
LOWER_LETTERS = string.ascii_lowercase
UPPER_LETTERS = string.ascii_uppercase
LETTERS = string.ascii_letters
LETTERS_DIGITS = LETTERS + DIGITS
LABEL_CHARS = LETTERS + '_'

MEM_DEPTH = 1024
WORD_WIDTH = 32
ADDR_PAD_SIZE = len(format(MEM_DEPTH-1, 'X'))
WORD_PAD_SIZE = len(format((2 ** WORD_WIDTH)-1, 'X'))
TEXT_SEGMENT = 'text'
DATA_SEGMENT = 'data'

MAX_REGISTERS = 32
REGISTERS = [ 'R' + str(i) for i in range(MAX_REGISTERS)]

INSTRUCTIONS = ['NOP', # NO OPERATION
				'LW', 'SW', # LOAD STORE
				'ADD', 'ADDI', 'ADDU', 'ADDUI', # ADDITION
				'SUB', 'SUBI', 'SUBU', 'SUBUI', # SUBTRACTION
				'AND', 'ANDI', # AND
				'OR', 'ORI', # OR
				'XOR', 'XORI', # XOR
				'SLL', 'SLLI', 'SRL', 'SRLI', 'SRA', 'SRAI', # SHIFT OPERATIONS
				'SLT', 'SLTI', 'SLTU', 'SLTUI', # LESS THAN
				'SGT', 'SGTI', 'SGTU', 'SGTUI', # GREATER THAN
				'SLE', 'SLEI', 'SLEU', 'SLEUI', # LESS THAN OR EQUAL
				'SGE', 'SGEI', 'SGEU', 'SGEUI', # GREATER THAN OR EQUAL
				'SEQ', 'SEQI', 'SNE', 'SNEI', # EQUAL NOT EQUAL
				'BEQZ', 'BNEZ', # BRANCH
				'J', 'JR', 'JAL', 'JALR' # JUMP
			]

OP_CODES_DICT = {INSTRUCTIONS[op]:op for op in range(len(INSTRUCTIONS))}

NO_OPS = [
			'NOP' # NO OPERATION
		]

MEMORY_OPS = [
				'LW', 'SW' # LOAD STORE
			]

BRANCH_OPS = [
				'BEQZ', 'BNEZ' # BRANCH
			]

JUMP_OPS = [
				'J', 'JR', 'JAL', 'JALR' # JUMP
			]

REGISTER_OPS = [
				'ADD', 'ADDU', # ADDITION
				'SUB', 'SUBU', # SUBTRACTION
				'AND', # AND
				'OR', # OR
				'XOR', # XOR
				'SLL', 'SRL', 'SRA', # SHIFT OPERATIONS
				'SLT', 'SLTU', # LESS THAN
				'SGT', 'SGTU', # GREATER THAN
				'SLE', 'SLEU', # LESS THAN OR EQUAL
				'SGE', 'SGEU', # GREATER THAN OR EQUAL
				'SEQ', 'SNE' # EQUAL NOT EQUAL
			]

IMMEDIATE_OPS = [
				'ADDI', 'ADDUI', # ADDITION
				'SUBI', 'SUBUI', # SUBTRACTION
				'ANDI', # AND
				'ORI', # OR
				'XORI', # XOR
				'SLLI', 'SRLI', 'SRAI', # SHIFT OPERATIONS
				'SLTI', 'SLTUI', # LESS THAN
				'SGTI', 'SGTUI', # GREATER THAN
				'SLEI','SLEUI', # LESS THAN OR EQUAL
				'SGEI', 'SGEUI', # GREATER THAN OR EQUAL
				'SEQI', 'SNEI' # EQUAL NOT EQUAL
			]

IMMEDIATE_EXPONENT = 16
IMM_MAX_UNSIGNED = (2 ** IMMEDIATE_EXPONENT) - 1
IMM_MIN_SIGNED = -1 * (2 ** (IMMEDIATE_EXPONENT-1))

MIF_PREAMBLE = f'''DEPTH = {MEM_DEPTH};
WIDTH = {WORD_WIDTH};
ADDRESS_RADIX = HEX;
DATA_RADIX = HEX;
CONTENT
BEGIN

'''

MIF_EPILOGUE = '\nEND;'