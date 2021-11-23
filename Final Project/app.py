from PIL import Image

out_file = open("font.txt", 'w')
img = Image.open("numbers.png")
pix = img.load()
size_x, size_y = img.size

for y in range(size_y):
	if (y) % 30 == 0:
		out_file.write("\n-- "+str((y+1)//30)+ "\n")
	line = '"'
	for x in range(size_x):
		if pix[x, y][0] < 180:
			line += '1'
		else:
			line += '0'

	line += '", -- ' + line.replace('0', ' ').replace('1', '#') + "\n"
	out_file.write(line)

out_file.close()