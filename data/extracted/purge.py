import os
folders = os.listdir()
for folder in folders:
	if not os.path.isdir(folder):
		continue
	files = os.listdir(folder)
	for file in files:
		if file.split('.')[-1] == 'txt':
			continue
		os.remove(os.path.join(folder,file))

folder = os.path.join('..','error')
files = os.listdir(folder)
for file in files:
	if file.split('.')[-1] == 'txt':
		continue
	os.remove(os.path.join(folder,file))