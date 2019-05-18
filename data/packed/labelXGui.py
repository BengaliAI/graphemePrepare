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
rows = 12
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
gridHeight = math.ceil(winHeight*.8)
gridWidth = math.ceil(winWidth*.8)
imgWidth = math.floor(gridWidth/cols)
imgHeight = math.floor(gridHeight/rows)
anchors = [[(cl,rw) for cl in range(0,gridWidth,imgWidth)] for rw in range(0,gridHeight,imgHeight)]
c = tk.Canvas(root, width=gridWidth, height=gridHeight, borderwidth=0, background='white')
c.pack()

tiles = [[None for _ in range(cols)] for _ in range(rows)]
path = 'M:/graphemePrepare/data/packed/BUETEEE18A/ং_BUETEEE18A_scan0048.png'
img = ImageTk.PhotoImage(Image.open(path).resize((imgWidth,imgHeight)))
def callback(event):
    # Calculate column and row number
    col = int(event.x//imgWidth)
    row = int(event.y//imgHeight)
    print(row,col)
    # If the tile is not filled, create a rectangle
    if not tiles[row][col]:
        tiles[row][col] = c.create_image(anchors[row][col][0],anchors[row][col][1],image=img, anchor='nw')
    # If the tile is filled, delete the rectangle and clear the reference
    else:
        c.delete(tiles[row][col])
        tiles[row][col] = None

c.bind("<Button-1>", callback)
root.mainloop()