#!/usr/bin/python

for num in range(1, 100):
  if num % 3 == 0:
    print('Fizz \n')
  elif num % 5 == 0:
    print('Buzz \n')
  elif num % 5 == 0 and num % 3 == 0:
    print('FizzBuzz \n')
  else:
    print(str(num) + ' \n')
print('End of Loop...')
