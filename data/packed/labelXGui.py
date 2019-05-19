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


class labelXGui(object):
    def __init__(self, target, rows, cols):
        """
        creates Gui object for annotation
        :param target: target filename
        :param rows: number of rows to display
        :param cols: number of columns to display
        """
        self.packetidx = 0
        self.rows = rows
        self.cols = cols
        self.packetSize = rows * cols
        self.root = tk.Tk()
        self.target = target
        self.targetConf = target + '.conf'
        self.packed = os.listdir(target)
        self.numPack = math.ceil(len(self.packed) / packetSize)
        self.chkConf()

    def chkConf(self):
        """
        Read/init config file
        """
        if os.path.isfile(self.targetConf):
            with open(self.targetConf, 'r', encoding='utf8') as readFile:
                csvIn = csv.reader(readFile)
                csvIn = list(csvIn)
                self.header = csvIn[0]
                self.packed = [each[0] for each in csvIn[1:]]
                self.annot = [each[1] for each in csvIn[1:]]
                self.annotPass = [each[2] for each in csvIn[1:]]
                if len(self.header) > 3:
                    self.metaList = [each[2:] for each in csvIn[1:]]
                else:
                    self.metaList = []
        else:
            self.header = ['filename', 'label', 'pass']
            self.annot = ['1'] * len(self.packed)
            self.annotPass = ['0'] * len(self.packed)
            self.confSave()
            self.metaList = []

    def confSave(self):
        """
        save configuration file
        """
        with open(self.targetConf, 'w', encoding='utf8') as writeFile:
            writer = csv.writer(writeFile, lineterminator='\n')
            writer.writerow(self.header)
            if len(self.header) < 4:
                writer.writerows([[scn, ent, pas] for scn, ent, pas in zip(self.packed,
                                                                           self.annot, self.annotPass)])
            else:
                writer.writerows([[scn, ent] + pas for scn, ent, pas in zip(self.packed,
                                                                            self.annot, self.annotPass)])


def confSave(filename, packed, annot, annotPass, header=('filename', 'label', 'pass')):
    with open(filename, 'w', encoding='utf8') as writeFile:
        writer = csv.writer(writeFile, lineterminator='\n')
        writer.writerow(header)
        if len(header) < 4:
            writer.writerows([[scn, ent, pas] for scn, ent, pas in zip(packed, annot, annotPass)])
        else:
            writer.writerows([[scn, ent] + pas for scn, ent, pas in zip(packed, annot, annotPass)])


def packetDisplay(canvas, packetidx, packetSize, target, packed, annotPass, imgWidth, imgHeight, anchors):
    '''
    display a set of graphemes for a given packetidx
    '''
    img = []
    idx = range(packetidx * packetSize, (packetidx + 1) * packetSize)
    for i, anchor in zip(idx, anchors):
        path = os.path.join(os.getcwd(), target, packed[i])
        img.append(ImageTk.PhotoImage(Image.open(path).resize((imgWidth, imgHeight))))
        canvas.create_image(anchor, image=img[-1], anchor='nw')
        annotPass[i] = '1'
    return img, annotPass


def updateAnnot(annot, row, col, packetidx, packetSize, rows):
    '''
    Update annotation for a given grapheme
    '''
    idx = range(packetidx * packetSize, (packetidx + 1) * packetSize)
    annot[idx + row + col * rows] = '0'
    return annot


packetidx = 0
rows = 12
cols = 15
packetSize = rows * cols
root = tk.Tk()
target = 'BUETEEE18A'
# target = sys.argv[1]
targetConf = target + '.conf'
packed = os.listdir(target)
numPack = math.ceil(len(packed) / packetSize)

### if conf exists
if os.path.isfile(targetConf):
    with open(targetConf, 'r', encoding='utf8') as readFile:
        csvIn = csv.reader(readFile)
        csvIn = list(csvIn)
        header = csvIn[0]
        packed = [each[0] for each in csvIn[1:]]
        annot = [each[1] for each in csvIn[1:]]
        annotPass = [each[2] for each in csvIn[1:]]
        if len(header) > 3:
            metaList = [each[2:] for each in csvIn[1:]]
        else:
            metaList = []
else:
    header = ['filename', 'label', 'pass']
    annot = ['1'] * len(packed)
    annotPass = ['0'] * len(packed)
    confSave(targetConf, packed, annot, annotPass, header)
    metaList = []

### Batchname and packetidx container
container = tk.LabelFrame(root, text='Bengali.AI Common Graphemes in Context')
container.pack(fill="both", expand="yes")
batchname = tk.StringVar()
label = tk.Label(container, textvariable=batchname)
label.pack(side='top')
batchname.set('BATCHNAME: ' + target)
packet = tk.StringVar()
packetid = tk.Label(container, textvariable=packet)
packetid.pack(side='right')
packet.set(str(packetidx) + '/' + str(numPack))

### create grid
gridHeight = math.ceil(winHeight * .8)
gridWidth = math.ceil(winWidth * .8)
imgWidth = math.floor(gridWidth / cols)
imgHeight = math.floor(gridHeight / rows)
anchors = [(cl, rw) for cl in range(0, gridWidth, imgWidth) for rw in range(0, gridHeight, imgHeight)]
c = tk.Canvas(root, width=gridWidth, height=gridHeight, borderwidth=0, background='white')
c.pack()

img, annotPass = packetDisplay(c, packetidx, packetSize, target, packed, annotPass, imgWidth, imgHeight, anchors)
tiles = [[None for _ in range(cols)] for _ in range(rows)]


def onClick(event):
    col = int(event.x // imgWidth)
    row = int(event.y // imgHeight)
    print(row, col)
    if not tiles[row][col]:
        tiles[row][col] = c.create_oval(col * imgWidth, row * imgHeight, (col + 1) * imgWidth, (row + 1) * imgHeight,
                                        stipple='gray50', width=2)
        updateAnnot(annot, row, col, packetidx, packetSize, rows)
    # If the tile is filled, delete the rectangle and clear the reference
    else:
        c.delete(tiles[row][col])
        tiles[row][col] = None
    print(annot)


c.bind("<Button-1>", onClick)
root.mainloop()
