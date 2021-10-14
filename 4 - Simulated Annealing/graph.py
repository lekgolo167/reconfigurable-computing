import matplotlib.pyplot as plt
import os, os.path

print("Collecting data ...")
x = []
y = []

letters = ['a','b','c','d']
path, dirs, files = next(os.walk("./data/"))
file_total = len(files)
print(file_total)
file_count = 0
file_total = file_total // len(letters)

while file_count < file_total:
	file_count += 1
	avg_cost = 0
	avg_time = 0
	for letter in letters:
		f = open(f'./data/output{file_count}{letter}.txt', 'r')
		avg_cost += int(f.readline())
		avg_time += int(f.readline())
		f.close()
	avg_cost /= 4
	avg_time /= 4
	x.append(avg_time)
	y.append(avg_cost)

plt.plot(x,y)

plt.title("Quality vs Runtime as Cooling Rate Is Adjusted")
plt.xlabel("Time (us) * 1E6")
plt.ylabel("Cost (lower is better)")

plt.show()