import tkinter as tk
from PIL import Image, ImageTk
import os
import sys
import csv
import math

### On windows get display size
try:
    from win32api import GetSystemMetrics
    winWidth = GetSystemMetrics(0)
    winHeight = GetSystemMetrics(1)
except:
    winWidth = 1920
    winHeight = 1080

### Utility functions
def confSave(filename,extrList,entryList,passList,header=['filename','label','pass']):
	with open(filename,'w',encoding='utf-8') as writeFile:
		writer = csv.writer(writeFile, lineterminator='\n')
		writer.writerow(header)
		if len(header)<4:
			writer.writerows([[scn,ent,pas] for scn,ent,pas in zip(extrList,entryList,passList)])
		else:
			writer.writerows([[scn,ent]+pas for scn,ent,pas in zip(extrList,entryList,passList)])

packetidx = 0
rows = 6
cols = 15
packetSize = rows*cols
root = tk.Tk()
target = 'BUETEEE18A'
#target = sys.argv[1]
targetConf = target+'.conf.csv'
extrList = os.listdir(target)
numPack = math.ceil(len(extrList)/packetSize)

### if conf exists
if os.path.isfile(targetConf):
	with open(targetConf,'r', encoding='utf-8') as readFile:
		csvIn = csv.reader(readFile)
		csvIn = list(csvIn)
		header = csvIn[0]
		extrList = [each[0] for each in csvIn[1:]]
		entryList = [each[1] for each in csvIn[1:]]
		passList = [each[2] for each in csvIn[1:]]
		if len(header)>3:
		    metaList = [each[2:] for each in csvIn[1:]]
		else:
			metaList = []
else:
	header = ['filename','label','pass']
	entryList = ['']*len(extrList)
	passList = ['']*len(extrList)
	confSave(targetConf,extrList,entryList,passList,header)
	metaList = []

### Batchname and packetidx container
container = tk.LabelFrame(root, text='Bengali.AI Common Graphemes in Context')
container.pack(fill="both", expand="yes")
batchname = tk.StringVar()
label = tk.Label(container, textvariable=batchname )
label.pack(side='top')
batchname.set('BATCHNAME: ' +target)
packet = tk.StringVar()
packetid = tk.Label(container, textvariable=packet)
packetid.pack(side='right')
packet.set(str(packetidx)+'/'+str(numPack))

### create grid
gridHeight = int(winHeight*.8)
gridWidth = int(winWidth*.8)
imgWidth = math.floor(gridWidth/cols)
imgHeight = math.floor(gridHeight/rows)
anchors = [each for each in zip(range(0,gridWidth,imgWidth),range(0,gridHeight,imgHeight))]
print(anchors)
c = tk.Canvas(root, width=gridWidth, height=gridHeight, borderwidth=0, background='white')
c.pack()

root.mainloop()