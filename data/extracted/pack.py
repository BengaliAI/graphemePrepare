import os
import shutil

folders = os.listdir()
for folder in folders:
	if not os.path.isdir(folder):
		continue
	files = os.listdir(folder)
	for file in files:
		if file.split('.')[-1] == 'txt':
			continue
		src = os.path.join(folder,file)
		batch = file.split('_')[0]
		dir = os.path.join('..','packed',batch)
		if not os.path.isdir(dir):
			os.mkdir(dir)
		dst = os.path.join(dir,folder+'_'+file)
		shutil.copy(src,dst)