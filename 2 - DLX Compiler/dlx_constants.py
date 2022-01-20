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

MIF_PREAMBLE = '''
DEPTH = 1024;
WIDTH = 32;
ADDRESS_RADIX = HEX;
CONTENT
BEGIN

'''

MIF_EPILOGUE = '''

END;
'''