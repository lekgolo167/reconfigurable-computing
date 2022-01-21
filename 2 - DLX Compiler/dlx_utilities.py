#######################################
# ERRORS
#######################################

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

    return result.replace('\t', '')

class Error:
	def __init__(self, pos_start, pos_end, error_name, details):
		self.pos_start = pos_start
		self.pos_end = pos_end
		self.error_name = error_name
		self.details = details

	def as_string(self):
		result = f'{self.error_name}: {self.details}\n'
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

class InvalidLoadValueError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, f'Invalid Register: Expected a load value from {IMM_MIN_SIGNED} to {IMM_MAX_UNSIGNED} but got ->', details)

class ExpectedRegisterError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, f'Expected Register: Expected a register value but got ->', details)

class InvalidJumpOperandError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, f'Invalid Jump Instruction: Expected a register value or label but got ->', details)

class ExpectedVariableError(Error):
	def __init__(self, pos_start, pos_end, details=''):
		super().__init__(pos_start, pos_end, f'Expected Variable: Expected a variable or array value but got ->', details)
