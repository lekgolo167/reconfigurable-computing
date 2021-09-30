import re

f = open('output.txt', 'r')
lst = []
m = 0
for line in f.readlines():
	if re.search(r"= ..", line):
		m += 1
		match = re.findall(r"= ..", line)[0][2:5]
	if match not in lst:
		lst.append(match)
print(m)
print(len(lst))