nums = [0] * 10
scratch = [0] * 10
print('enter 10 numbers')
for i in range(len(nums)):
	x = int(input())
	nums[i] = x
	scratch[i] = x

def is_done():
	for i in range(0, len(nums)-1):
		if scratch[i] != scratch[i+1]:
			return False
	return True

def incr():
	for i in range(len(nums)-1):
		while scratch[i] < scratch[i+1]:
			scratch[i] += nums[i]

	for i in range(len(nums)-1,-1,-1):
		while scratch[i-1] > scratch[i]:
			scratch[i] += nums[i]

while not is_done():
	incr()

print('done')
for n in scratch:
	print(n)