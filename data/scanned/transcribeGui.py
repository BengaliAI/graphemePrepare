import tkinter as tk
from PIL import Image, ImageTk
import os
import sys
import csv

### Utility functions
def renameSave(filename,scanList,entryList,metaList,header=['filename','ID']):
	with open(filename,'w') as writeFile:
		writer = csv.writer(writeFile, lineterminator='\n')
		writer.writerow(header)
		if len(header)<3:
			writer.writerows([[scn,ent] for scn,ent in zip(scanList,entryList)])
		else:
			writer.writerows([[scn,ent]+meta for scn,ent,meta in zip(scanList,entryList,metaList)])

### Initialize counter list and roi in scan
idx = 0
root = tk.Tk()
target = 'RIFLESSCH1'
target = sys.argv[1]
scanList = os.listdir(target)
roi = (500,0,1900,500)

### if trancsription exists
if os.path.isfile(target+'.csv'):
	with open(target+'.csv','r') as readFile:
		csvIn = csv.reader(readFile)
		csvIn = list(csvIn)
		header = csvIn[0]
		scanList = [each[0] for each in csvIn[1:]]
		entryList = [each[1] for each in csvIn[1:]]
		if len(header)>2:
		    metaList = [each[2:] for each in csvIn[1:]]
		else:
			metaList = []
else:
	header = ['filename','ID']
	entryList = ['']*len(scanList)
	renameSave(target+'.csv',scanList,entryList,header)
	metaList = []

### display filename and entry panel
container = tk.LabelFrame(root, text='Bengali.AI Common Graphemes in Context')
container.pack(fill="both", expand="yes")
filename = tk.StringVar()
label = tk.Label(container, textvariable=filename )
label.pack(side='left')
filename.set('Filename: '+scanList[idx])

dispText = tk.StringVar()
studentid = tk.Entry(container, text='Student ID/Roll', bd =5, width=50, textvariable=dispText)
studentid.pack(side='right')
dispText.set(entryList[idx])

### display image of first scan
path = os.path.join(target,scanList[idx])
img = ImageTk.PhotoImage(Image.open(path).crop(roi))
panel = tk.Label(root, image=img, textvariable=filename)
panel.pack(side="bottom", fill="both", expand="yes")

### callbacks for each keypress events
def rightKey(e):
	global idx
	entryList[idx] = studentid.get()
	idx += 1
	if idx>len(scanList)-1:
		idx=len(scanList)-1
	img = ImageTk.PhotoImage(Image.open(os.path.join(target,scanList[idx])).crop(roi))
	panel.configure(image=img)
	panel.image = img
	filename.set('Filename: '+scanList[idx])
	dispText.set(entryList[idx])
	renameSave(target+'.csv',scanList,entryList,metaList,header)

def leftKey(e):
    global idx
    entryList[idx] = studentid.get()
    idx -= 1
    if idx<0:
    	idx = 0
    img = ImageTk.PhotoImage(Image.open(os.path.join(target,scanList[idx])).crop(roi))
    panel.configure(image=img)
    panel.image = img
    filename.set('Filename: '+scanList[idx])
    dispText.set(entryList[idx])
    renameSave(target+'.csv',scanList,entryList,metaList,header)

### Bind key to callbacks
root.bind('<Alt-Left>', leftKey)
root.bind('<Alt-Right>', rightKey)
root.bind('<Return>', rightKey)
root.bind('<Tab>', rightKey)
root.mainloop()

