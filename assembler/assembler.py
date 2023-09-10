from constants import *

import re
import argparse

def read_file(file_path):
	in_file = open(file_path, "r")
	contents = in_file.read().split("\n")
	return contents

def write_file(file_path, contents):
	out_file = open(file_path, "w")
	for index in range(len(contents)):
		out_file.write(contents[index])
		if index != len(contents) - 1:
			out_file.write("\n")

def get_assembler_tokens(lines):
	tokens = []
	line_nums = []
	for (line_num, line) in enumerate(lines):
		tokens.append(extract_tokens_from_line(line))
		line_nums.append(line_num + 1)
	return tokens, line_nums

def extract_tokens_from_line(line):
	hashtag = line.find("#")
	if hashtag > -1:
		line = line[:hashtag]
	semicolon = line.find(";")
	if semicolon > -1:
		line = line[:semicolon]
	tokens = re.split(',| |\t', line)
	return [t.strip() for t in tokens if t != '']

def get_machine_code(tokenized_lines, line_nums):
	machine_codes = []
	index = 0
	while index < len(tokenized_lines):
		if len(tokenized_lines[index]) == 0:
			del tokenized_lines[index]
			del line_nums[index]
			index -= 1
		for token in tokenized_lines[index]:
			colon = token.find(":")
			if colon > -1 and len(token) > 1:
				tokenized_lines[index].remove(token)
				b_label = False
				if len(tokenized_lines[index]) == 0:
					del tokenized_lines[index]
					del line_nums[index]
					b_label = True
				num_nops = pad_nops(tokenized_lines, line_nums, index)
				index += num_nops
				BRANCH_MAP[token[:colon]] = index
				if b_label:
					index -= 1
		
		index += 1

	for index in range(len(tokenized_lines)):
		machine_codes.append(instruction_parser(tokenized_lines[index], line_nums[index]))
		
	return machine_codes

def pad_nops(tokenized_lines, line_nums, index):
	multiples_of = (2**BXAMT)
	num_nops = multiples_of - (index % multiples_of)
	next_line_num = line_nums[index]
	if num_nops == multiples_of:
		num_nops = 0
	for i in range(num_nops):
		tokenized_lines.insert(index, ["NIL"])
		line_nums.insert(index, next_line_num)
	return num_nops

def get_move_machine_code(instruction, line):
	args = instruction[1:]
	machine_code = list('000000000')
	machine_code[0] = '0'
	machine_code[1:5] = get_register_repr(args[0], line)
	machine_code[5:9] = get_register_repr(args[1], line)
	return machine_code

def get_arithmetics_machine_code(opcode, arg, line):
	machine_code = list('000000000')
	instr_map = {
		'AND': '1110010',
		'OR': '1110011',
		'NOT': '1110100',
		'XOR': '1110101',
		'ADD': '1110000',
		'SUB': '1110001',
		'EOR': '1111100',
	}
	machine_code[0:7] = instr_map[opcode]
	machine_code[7:] = get_register_repr(arg, line)[-2:]
	return machine_code

def instruction_parser(instruction_tokens, line_num):
	machine_code = list('000000000')
	try:
		op = instruction_tokens[0]
		args = instruction_tokens[1:]

		if op == "MOV":
			machine_code = get_move_machine_code(instruction_tokens, line_num)
		elif op == "BRN":
			machine_code[0:3] = '100'
			immediate = args[0]
			immediate_marker = immediate.find("$")
			if immediate_marker > -1:
				branch_name = immediate[immediate_marker + 1:]
				try:
					immed_int = BRANCH_MAP[branch_name] >> BXAMT
					immediate = str(immed_int)
				except KeyError:
					print("Error on line {}: no such branch label \'{}\' exists".format(line_num, branch_name))
					immediate = "0"
			machine_code[3:]= get_immediate(immediate, 0, 2**6-1, 6, line_num)
		elif op == "SET":
			machine_code[0:3] = '101'
			machine_code[3:] = get_immediate(args[0], 0, 2**6-1, 6, line_num)
		elif op == "LSL":
			machine_code[0:4] = '1100'
			if check_register(args[0], ["R8", "R9", "RA", "RB"], line_num):
				machine_code[4:6] = get_register_repr(args[0], line_num)[-2:]
			if len(args) > 1:
				machine_code[6:] = get_immediate(args[1], 1, 7, 3, line_num)
			else:
				machine_code[6:]  = "000"
		elif op == "LSR":
			machine_code[0:4] = '1101'
			if check_register(args[0], ["R8", "R9", "RA", "RB"], line_num):
				machine_code[4:6] = get_register_repr(args[0], line_num)[-2:]
			if len(args) > 1:
				machine_code[6:] = get_immediate(args[1], 1, 7, 3, line_num)
			else:
				machine_code[6:] = "000"
		elif op == "LDB":
			machine_code[0:6] = '111100'
			if check_register(args[0], ['R' + str(i) for i in range(8)], line_num):
				machine_code[6:] = get_register_repr(args[0], line_num)[-3:]
		elif op == "STB":
			machine_code[0:6] = '111101'
			if check_register(args[0], ['R' + str(i) for i in range(8)], line_num):
				machine_code[6:] = get_register_repr(args[0], line_num)[-3:]
		elif op[0:3] == "FLG":
			machine_code[0:6] = '111011'
			flags = ["N", "Q", "L", "E", "J"]
			ind = flags.index(op[3])
			if op[3] not in flags:
				raise Exception('Unknown JUMP flag detected')
			machine_code[6:] = bin(int(ind))[2:].zfill(3)
		elif op in ['AND', 'OR', 'NOT', 'XOR', 'ADD', 'SUB', 'EOR']:
			machine_code = get_arithmetics_machine_code(op, args[0], line_num)
		elif op == "NIL":
			machine_code = '111111110'
		elif op == "done" or op == "DONE":
			machine_code = "111111111"
		else:
			raise Exception(f'Invalid OPCODE Detected: {op}')
	except:
		raise Exception(f'Unknown Instruction detected: {instruction_tokens}')
	return ''.join(machine_code)

def check_register(register, valid_registers, line_num):
	if register in valid_registers:
		return True
	
	raise Exception(f'Invalid Register {register} detected on line {line_num}')

def get_register_repr(register, line_num):
	register = register.upper()
	intermediate_register_num = '0x' + register[1]
	try:
		register_num = int(intermediate_register_num, 16)
	except:
		raise Exception(f'Unknown register {register} detected on line {line_num}!')
	return bin(register_num)[2:].zfill(4)

def get_immediate(immediate, min, max, size, line_num):
	if 'x' in immediate or 'X' in immediate:
		immediate = int(immediate, 16)
	elif 'b' in immediate or 'B' in immediate:
		immediate = int(immediate, 2)
	else:
		immediate = int(immediate)
	if immediate < min or immediate > max:
		raise Exception(f'Invalid Immediate {immediate} detected on line {line_num}')
	return bin(immediate)[2:].zfill(size)

def main():
	ap = argparse.ArgumentParser()
	ap.add_argument("input")
	ap.add_argument("output")
	args = ap.parse_args()
	input_contents = read_file(args.input)
	tokens, line_nums = get_assembler_tokens(input_contents)
	machine_code  = get_machine_code(tokens, line_nums)
	write_file(args.output, machine_code)

if __name__ == '__main__':
	main()