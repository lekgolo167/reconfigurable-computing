f = open('output.txt', 'r')
lst = []
m = 0
for line in f.readlines():
	m += 1
	line = line.strip()
	if len(line) > 1  and line not in lst:
		lst.append(line)

print(m)
print(len(lst))
