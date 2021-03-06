#######################################
# ERRORS
#######################################

from dlx_constants import *

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    # Background colors:
    GREYBG = '\033[100m'
    REDBG = '\033[101m'
    GREENBG = '\033[102m'
    YELLOWBG = '\033[103m'
    BLUEBG = '\033[104m'
    PINKBG = '\033[105m'
    CYANBG = '\033[106m'

def string_with_arrows(text, pos_start, pos_end):
	result = ''

	# Calculate indices
	idx_start = max(text.rfind('\n', 0, pos_start.idx), 0)
	idx_end = text.find('\n', idx_start + 1)
	if idx_end < 0: idx_end = len(text)

	# Generate each line
	line_count = pos_end.ln - pos_start.ln + 1
	for i in range(line_count):
		# Calculate line columns
		line = text[idx_start:idx_end]
		col_start = pos_start.col if i == 0 else 0
		col_end = pos_end.col if i == line_count - 1 else len(line) - 1

		# Append to result
		result += line + '\n'
		result += ' ' * col_start + '^' * (col_end - col_start)

		# Re-calculate indices
		idx_start = idx_end
		idx_end = text.find('\n', idx_start + 1)
		if idx_end < 0: idx_end = len(text)

	return result.strip().replace('\t', '  ')

class Error:
	def __init__(self, pos_start, pos_end, error_name, details, color=bcolors.FAIL):
		self.pos_start = pos_start
		self.pos_end = pos_end
		self.error_name = error_name
		self.details = details
		self.color = color

	def __repr__(self) -> str:
		return f'{self.color}{self.error_name}{bcolors.ENDC}: {self.details}\n'

	def as_string(self):
		result = f'{self.color}{self.error_name}{bcolors.ENDC}: {self.details}\n'
		result += f'File {self.pos_start.fn}, line {self.pos_start.ln + 1}'
		result += '\n\n' + \
			string_with_arrows(self.pos_start.ftxt,
							   self.pos_start, self.pos_end)
		return result

class IllegalCharError(Error):
	def __init__(self, pos_start, pos_end, details):
		super().__init__(pos_start, pos_end, 'Illegal Character', details)

class InvalidSyntaxError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Invalid Syntax', details)

class InvalidInstructionError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Invalid Instruction: Expected a valid DLX instruction but got ->', details)		

class InvalidRegisterError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, f'Invalid Register: Expected a Register from 0-{MAX_REGISTERS-1} but got ->', details)

class InvalidStringError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, f'Invalid String: Expected a closing (") character', '')

class InvalidLoadValueError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, f'Invalid Register: Expected a load value from {IMM_MIN_SIGNED} to {IMM_MAX_UNSIGNED} but got ->', details)

class ExpectedRegisterError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Expected Register: Expected a register value but got ->', details)

class InvalidJumpOperandError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Invalid Jump Instruction: Expected a register value or label but got ->', details)

class ExpectedVariableError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Expected Variable: Expected a variable or array value but got ->', details)

class ExpectedVariableSizeError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Expected Variable Size: Expected a number for variable size but got->', details)

class UnexpectedEndOfArrayError(Error):
	def __init__(self, pos_start, pos_end, size, index, details=''):
		super().__init__(pos_start, pos_end, f'Unexpected End of Array: Expected {size} numbers but got found {index} and instead received ->', details)

class InvalidDataSectionError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Invalid Data Segment: Only variables or arrays are allowed in a data segment but got ->', details)

class ExpectedIntegerError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Expected Number: Expected a number but got ->', details)

class ExpectedLabelError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Expected Label: Expected a label but got ->', details)

class NoDataSectionFoundError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'No Data Segment: No data segment found or the text section was found first but found ->', details)

class UnexpectedSegmentError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, f'Unexpected Segment: Expected a {TEXT_SEGMENT} segment but found ->', details)

class VariableRedeclarationError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Variable Redeclaration: The following variable has been declared more than once ->', details)

class LabelRedeclarationError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Label Redeclaration: The following label has been declared more than once ->', details)

class LabelReferencedButNotDeclaredError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Undeclared Label Reference: The following label has been referenced but not declared ->', details)

class VariableReferencedButNotDeclaredError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Undeclared Variable Reference: The following variable has been referenced but not declared ->', details)

class InvalidDestinationRegisterError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, 'Invalid Destination Register: The destination register can never be R0 as it is read-only ->', details)

class UnusedVariableWarning(Error):
	def __init__(self, details=''):
		super().__init__(-1, -1, 'Warning: The following variable was declared but not referenced ->', details, bcolors.WARNING)
