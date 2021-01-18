i=0
while i <=10:
    print(i)
    i+=1
    
for j in 'hello world':
    if j =='w':
        continue
    print(j*2)
    
for j in 'hello world':
    if j =='a':
        break
    print(j*2)
else:
    print("net 'A'")
