

# print('Running Lab3:')


import sys
#fileObj = open("filename", "mode") 
filename = sys.argv[1]
loop_Indicator = False
loop_num = -1
if len(sys.argv) > 2:
  loop_Indicator = True
  loop_num = 1
print(filename)

read_file = open(filename, "r") 

#Print read_file

#w_file is the file we are writing to

w_file = open("machine_code.txt", "w")


#Open a file name and read each line
#to strip \n newline chars
#lines = [line.rstrip('\n') for line in open('filename')]  

#1. open the file
#2. for each line in the file,
#3.     split the string by white spaces
#4.      if the first string == SET then op3 = 0, else op3 = 1
#5.
# 


## not needed anymore ?
# def parseCode(str):
#   res = []
#   for i in range(len(str)):
#     res.append(str[i])
#   return res

def parseCode(str):
  return str


def decimalNumToBinaryString(x):
  if x == 0:
    return "0"
  if x == 1:
    return "1"
  if x > 1:
    return decimalNumToBinaryString(x // 2) + str(x%2)

def processDecimal(x):
  res = decimalNumToBinaryString(int(x))
  return (8-len(res)) * "0" + res

def parseLookupIndex(x):
  res = decimalNumToBinaryString(int(x))
  return (6-len(res)) * "0" + res

def processReg(str):
  if str == "reg0":
    return "000"
  if str == "reg1":
    return "001"
  if str == "reg2":
    return "010"
  if str == "reg3":
    return "011"
  if str == "reg4":
    return "100"
  if str == "reg5":
    return "101"
  if str == "reg6":
    return "110"
  if str == "reg7":
    return "111"
  else:
    return "BAAAAAAAAAAAAAAAAAAAAAAAAAAAD"


with open(filename, 'r') as f:
  for line in f:
    if (line[0] == "#" or line[0] == "\n"):
      continue
    print (line)
    str_array = line.split()
    instr = str_array[0]
    # op = [" "] * 9
    # op1 = [" "] * 9
    # op2 = [" "] * 9
    # op3 = [" "] * 9
    ops = []
    # print (instruction)
    # print (str_array)

    if instr == "NOOP":
      op = parseCode("011100000")
      ops.append(op)

    elif instr == "EXIT":
      op = parseCode("111111111")
      ops.append(op)

    elif instr == "IMM":
      if str_array[1] == "acc":
        op = parseCode(processDecimal(str_array[2]) + "1")
        ops.append(op)
      else:
        op = parseCode("011111110") # save acc to reg7
        op1 = parseCode(processDecimal(str_array[2]) + "1") # save imm to acc
        op2 = parseCode("0111" + processReg(str_array[1]) + "10") # save imm to reg
        op3 = parseCode("011111100") # restore reg7 to acc
        ops.append(op)
        ops.append(op1)
        ops.append(op2)
        ops.append(op3)

    elif instr == "MOV":
      if str_array[1] == "acc":
        reg = processReg(str_array[2])
        op = parseCode("0111" + reg + "00")
        ops.append(op)
      elif str_array[2] == "acc":
        reg = processReg(str_array[1])
        op = parseCode("0111" + reg + "10")
        ops.append(op)
      else:
        op = parseCode("011111110") # save acc to reg7
        op1 = parseCode("0111" + processReg(str_array[2]) + "00")
        op2 = parseCode("0111" + processReg(str_array[1]) + "10")
        op3 = parseCode("011111100") # restore reg7 to acc
        ops.append(op)
        ops.append(op1)
        ops.append(op2)
        ops.append(op3)

    elif instr == "LDR":
      if len(str_array) == 2:
        op = parseCode("0001"+processReg(str_array[1]) + "00")
        ops.append(op)
      elif str_array[1] == "acc":
        op = parseCode("0001"+processReg(str_array[2]) + "00")
        ops.append(op)
      else:
        targetReg = processReg(str_array[1])
        sourceReg = processReg(str_array[2])
        op = parseCode("011111110") # save acc to reg7
        op1 = parseCode("0001" + sourceReg + "00") # load into acc
        op2 = parseCode("0111" + targetReg + "10") # move result from acc to target
        op3 = parseCode("011111100") # restore reg7 to acc
        ops.append(op)
        ops.append(op1)
        ops.append(op2)
        ops.append(op3)
        
    elif instr == "STR":
      if len(str_array) == 2 :
        op = parseCode("0000"+processReg(str_array[1]) + "00")
        ops.append(op)
      elif str_array[1] == "acc" :
        op = parseCode("0000"+processReg(str_array[2]) + "00")
        ops.append(op)
      else:
        sourceReg = processReg(str_array[1])
        targetReg = processReg(str_array[2])
        op = parseCode("011111110") # save acc to reg7
        op1 = parseCode("0111" + sourceReg + "00") # save source value to acc
        op2 = parseCode("0000" + targetReg + "00") # str acc value to target addr
        op3 = parseCode("011111100") # restore reg7 to acc
        ops.append(op)
        ops.append(op1)
        ops.append(op2)
        ops.append(op3)
    

    elif instr == "LFSR_UPDATE":
      # Usage: LFSR reg1(LFSR_STATE) reg2(lfsr_ptrn)
      if (len(str_array) != 3): 
        ops.append("BAAAAAAAAAAAD LFSR Process")
      else:
        LFSR_STATE = processReg(str_array[1])
        lfsr_ptrn = processReg(str_array[2])
        op = parseCode("011111110") # save acc to reg7
        op1 = parseCode("0"+"111"+LFSR_STATE+"00") # mov lfsr_state to acc
        op2 = parseCode("0" + "101" + lfsr_ptrn + "00")  # And acc lfsr_state lfsr_ptrn, does not write to acc
        op3 = parseCode("0" + "110" + LFSR_STATE + "10") # store lsled (after injecting parity) new state into LFSR_STATE
        op4 = parseCode("011111111") # forcing the 7 bit for LFSR
        op5 = parseCode("0101" + LFSR_STATE + "10") # forcing the 7 bit for LFSR
        op6 = parseCode("011111100") # restore reg7 to acc
        ops.append(op)
        ops.append(op1)
        ops.append(op2)
        ops.append(op3)
        ops.append(op4)
        ops.append(op5)
        ops.append(op6)




    # LSL needs state from last state, so cannot wrap!
    # must followed with XOR
    elif instr == "LSL":
      if len(str_array) == 2 and str_array[1] == "acc":
        # make sure parityQ / ZeroQ is correct
        op = parseCode("011111110") # save acc to reg7
        op1 = parseCode("0111"+"000"+"00")
        op2 = parseCode("0110"+"000"+"00")
        op3 = parseCode("011111100") # restore reg7 to acc
        ops.append(op)
        ops.append(op1)
        ops.append(op2)        
        ops.append(op3) 
      elif len(str_array) == 2:
        op = parseCode("011111110") # save acc to reg7
        op1 = parseCode("0111"+processReg(str_array[1])+"00")
        op2 = parseCode("0110"+"000"+"00")
        op3 = parseCode("0111"+processReg(str_array[1])+"10")
        op4 = parseCode("011111100") # restore reg7 to acc
        ops.append(op)
        ops.append(op1)
        ops.append(op2)        
        ops.append(op3) 
        ops.append(op4) 

    # branching does not save accumulator
    # (B #) -> # is lookup table index
    # loop, used with LOOP_BEGIN
    elif instr == "LOOP":
      op1 = parseCode("000000011") #load 1 to acc
      if len(str_array) == 3:
        op2 = parseCode("001111010") #reg6 = reg6 - 1, we have the Zero flag from ALU
      elif len(str_array) == 4:
        op2 = parseCode("0011"+processReg(str_array[3])+"10") #targreg = targreg - 1
      # on next step, ZeroQ is set for flag checking, automatically done in pc
      # absolute branching
      if str_array[1] == "A":
        op3 = parseCode("11" + parseLookupIndex(str_array[2]) + "0")
      # relative branching
      elif str_array[1] == "R":
        op3 = parseCode("10" + parseLookupIndex(str_array[2]) + "0")

      ops.append(op1)    
      ops.append(op2)
      ops.append(op3)
      if loop_Indicator:
        ops.append("above line is branching for loop" + str_array[2])

    elif instr == "LOOP_BEGIN":
      if loop_Indicator:
        ops.append("begin of loop " + str_array[1])
      else:
        continue

    # conditional branching
    elif instr == "B":
      # on next step, ZeroQ is set for flag checking, automatically done in pc
      # absolute branching
      if str_array[1] == "A":
        op = parseCode("11" + parseLookupIndex(str_array[2]) + "0")
      # relative branching
      elif str_array[1] == "R":
        op = parseCode("10" + parseLookupIndex(str_array[2]) + "0")
      ops.append(op)
      if loop_Indicator:
        ops.append("branch to lookup table index " + str_array[2])

    else:
      if instr == "ADD":
        opCode = "010"
      elif instr == "SUB":
        opCode = "011"
      elif instr == "XOR":
        opCode = "100"
      elif instr == "AND":
        opCode = "101"
      if len(str_array) == 2:
        op = parseCode("0" + opCode + processReg(str_array[1]) + "10")
        ops.append(op)
      elif str_array[1] == "acc":
        op = parseCode("0" + opCode + processReg(str_array[2]) + "00")
        ops.append(op)
      # elif str_array[2] == "acc":
      #   op = parseCode("0" + opCode + processReg(str_array[1]) + "10")
      #   ops.append(op)
      else:
        reg1 = processReg(str_array[1])
        reg2 = processReg(str_array[2])
        op = parseCode("011111110") # save acc to reg7
        op1 = parseCode("0" + "111" + reg2 + "00") # mov operand2 into acc
        op2 = parseCode("0" + opCode + reg1 + "10") # operand1 = operand2 operation operand1
                                    # for sub, (SUB A B) => A = A - B (acc being minused)
        op3 = parseCode("011111100") # restore reg7 to acc
        ops.append(op)
        ops.append(op1)
        ops.append(op2)
        ops.append(op3)

    # else:
    #   op[8] = "0"

    #   if instr == "B":
    #     op[0:2] = ["1", "0"]
    #   else:
    #     op[0] = "0"

    #     if instr == "STR":
    #       op[1:4] = parseCode("000")
    #     if instr == "LDR":
    #       op[1:4] = parseCode("001")
    #     if instr == "ADD":
    #       op[1:4] = parseCode("010")
    #     if instr == "SUB":
    #       op[1:4] = parseCode("011")
    #     if instr == "XOR":
    #       op[1:4] = parseCode("100")
    #     if instr == "AND":
    #       op[1:4] = parseCode("101")
    #     if instr == "LSL":
    #       op[1:4] = parseCode("110")
    #     if instr == "NOOP":
    #       op[1:9] = parseCode("1110000")



    # immFlag = instr[8]
    # if immFlag:

    # opFlag = instr[0]

    # if instruction == "SET":
    #   op3 = "1"
    #   imm = str_array[1]  #need to reformat without the hashtag
    #   imm = imm[1:]
    #   bin_imm = '{0:08b}'.format(int(imm)) #8 bit immediate
    #   #str_array[2] should be the comment
    #   return_set = op3 + bin_imm + '\t' + "#" + " " + instruction
    #        + " " + "#" + imm 
    #   w_file.write(return_set + '\n')
    # else:
    #   op3 = "0"      
    #   op1 = str_array[1]

    #   if instruction == "LB":
    #     opcode = "000"
    #     op2 = str_array[2]
    #   elif instruction == "SB":
    #     opcode = "001" 
    #     op2 = str_array[2]
    #   elif instruction == "XOR":
    #     opcode = "010"
    #     op2 = str_array[2]
    #   elif instruction == "AND":
    #     opcode = "011"
    #     op2 = str_array[2]
    #   elif instruction == "ADD":
    #     opcode = "100" 
    #     op2 = str_array[2]
    #   elif instruction == "SLP": 
    #     opcode = "101"
    #     op2 = "000"         # slp only has 1 arg
    #   elif instruction == "CMP":
    #     opcode = "110"
    #     op2 = str_array[2]
    #   elif instruction == "BNE":
    #     opcode = "111" 
    #     op2 = "000"         # bne only has 1 arg
    #   else:
    #     opcode = "error: undefined opcode"
    #     print ("error: undefined opcode")
    

    #   if ((op1 == "$t2" or op1 == "$t3" or op1 == "$t4") 
    #         or (op2 == "$t2" or op2 == "$t3" or op2 == "$t4")):
    #      level = "1"
    #   else:
    #      level = "0"

    #   print (op1)

    #   if (op1 == "$r0,"):
    #     reg1 = "00"
    #   elif (op1 == "$LFSR,"):
    #     reg1 = "01"
    #   elif (op1 == "$t0,"):
    #     reg1 = "10" 
    #   elif (op1 == "$t1,"):
    #     reg1 = "11"
    #   elif (op1 == "$t2,"):
    #     reg1 = "01"
    #   elif (op1 == "$t3,"):
    #     reg1 = "10"
    #   elif (op1 == "$t4,"):
    #     reg1 = "11"

    #   if (op2 == "$r0"):
    #     reg2 = "00"
    #   elif (op2 == "$LFSR"):
    #     reg2 = "01"
    #   elif (op2 == "$t0"):
    #     reg2 = "10" 
    #   elif (op2 == "$t1"):
    #     reg2 = "11"
    #   elif (op2 == "$t2"):
    #     reg2 = "01"
    #   elif (op2 == "$t3"):
    #     reg2 = "10"
    #   elif (op2 == "$t4"):
    #     reg2 = "11"

    #   if op2 == "000":
    #     return_rtype = op3 + opcode + reg1 + reg2 + level \
    #                 + '\t' + "#" + " " + instruction \
    #                 + " " + op1 
    #   else:
    #     return_rtype = op3 + opcode + reg1 + reg2 + level \
    #                 + '\t' + "#" + " " + instruction \
    #                 + " " + op1 + " " + op2
        

    for _op in ops:
      w_file.write(_op + '\n' )


w_file.close()
   

      


