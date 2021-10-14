import subprocess

num = 1
letters = ['a', 'b', 'c', 'd']
cooling = 0.00006103515625

while cooling < 1.0:
	procs = []
	for letter in letters:
		command = f"./a.out input3.txt data/output{num}{letter}.txt 1000000000 {cooling} 0.01"
		process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
		procs.append(process)

	for p in procs:
		p.wait()

	cooling += 0.00006103515625
	num += 1

	print(cooling)
