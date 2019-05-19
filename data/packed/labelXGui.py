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
        self.numPack = math.ceil(len(self.packed) / self.packetSize)
        self.chkConf()
        self.c = self.frameInit()
        self.showPacket(self.packetidx)
        self.c.bind("<Button-1>", self.onClick)
        self.root.bind("<Alt-Right>", self.nextPacket)
        self.root.bind("<Alt-Left>", self.prevPacket)
        self.root.bind("<Control-Key-s>", self.confSave)

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
                ### set packetidx to latest annotated packet
                try:
                    index = self.annotPass.index('0')
                    self.packetidx = index // self.packetSize - 1
                except ValueError:
                    self.packetidx = 0
        else:
            self.header = ['filename', 'label', 'pass']
            self.annot = ['1'] * len(self.packed)
            self.annotPass = ['0'] * len(self.packed)
            self.confSave()
            self.metaList = []

    def confSave(self,event=None):
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
                writer.writerows([[scn, ent, pas] + meta for scn, ent, pas, meta in zip(self.packed,
                                                                            self.annot, self.annotPass,self.metaList)])
        print(self.targetConf+' Saved')

    def frameInit(self):
        """
        Create Gui containers
        :returns: tkinter canvas object
        """
        global winHeight, winWidth
        self.container = tk.LabelFrame(self.root, text='Bengali.AI Common Graphemes in Context')
        self.container.pack(fill="both", expand="yes")
        self.batchname = tk.StringVar()
        self.label = tk.Label(self.container, textvariable=self.batchname)
        self.label.pack(side='top')
        self.batchname.set('BATCHNAME: ' + self.target)
        self.packet = tk.StringVar()
        self.packetDisp = tk.Label(self.container, textvariable=self.packet)
        self.packetDisp.pack(side='right')
        self.packet.set(str(self.packetidx) + '/' + str(self.numPack-1))

        ### add buttons
        self.save = tk.Button(self.container, text="SAVE", command=self.confSave)
        self.save.pack(side='right')
        self.next = tk.Button(self.container, text="NEXT", command=self.nextPacket)
        self.next.pack(side='right')
        self.prev = tk.Button(self.container, text="PREV", command=self.prevPacket)
        self.prev.pack(side='right')

        ### create grid
        self.gridHeight = math.ceil(winHeight * .8)
        self.gridWidth = math.ceil(winWidth * .8)
        self.imgWidth = math.floor(self.gridWidth / self.cols)
        self.imgHeight = math.floor(self.gridHeight / self.rows)
        self.anchors = [(cl, rw) for cl in range(0, self.gridWidth, self.imgWidth)
                        for rw in range(0, self.gridHeight, self.imgHeight)]
        c = tk.Canvas(self.root, width=self.gridWidth,
                           height=self.gridHeight, borderwidth=0, background='white')
        c.pack()
        return c

    def nextPacket(self,event=None):
        self.packetidx += 1
        if self.packetidx > self.numPack-1:
            self.packetidx = self.numPack-1
        self.packet.set(str(self.packetidx) + '/' + str(self.numPack - 1))
        self.showPacket(self.packetidx)
        # self.confSave()

    def prevPacket(self,event=None):
        self.packetidx -= 1
        if self.packetidx < 0:
            self.packetidx = 0
        self.packet.set(str(self.packetidx) + '/' + str(self.numPack - 1))
        self.showPacket(self.packetidx)
        # self.confSave()

    def showPacket(self,packetidx):
        """
        Displays packet for current packetidx and updates annotPass
        """
        self.tiles = [[None for _ in range(self.cols)] for _ in range(self.rows)]
        self.imgBuff = []
        idx = range(packetidx * self.packetSize, (packetidx + 1) * self.packetSize)
        for enum, each in enumerate(zip(idx, self.anchors)):
            i,anchor = each
            path = os.path.join(os.getcwd(), self.target, self.packed[i])
            self.imgBuff.append(ImageTk.PhotoImage(Image.open(path).resize((self.imgWidth, self.imgHeight))))
            self.c.create_image(anchor, image=self.imgBuff[-1], anchor='nw')
            if self.annot[i] == '0':
                col = enum // self.rows
                row = enum % self.rows
                self.tiles[row][col] = self.c.create_oval(col * self.imgWidth, row * self.imgHeight,
                                                          (col + 1) * self.imgWidth,
                                                          (row + 1) * self.imgHeight,
                                                          stipple='gray50', width=2)
            self.c.create_text(anchor,text=self.packed[i].split('_')[0], anchor='nw')
            self.annotPass[i] = '1'

    def onClick(self,event):
        col = int(event.x // self.imgWidth)
        row = int(event.y // self.imgHeight)
        # print(row, col)
        if not self.tiles[row][col]:
            self.tiles[row][col] = self.c.create_oval(col * self.imgWidth, row * self.imgHeight,
                                                      (col + 1) * self.imgWidth,
                                                      (row + 1) * self.imgHeight,
                                                      stipple='gray50', width=2)
            self.updateAnnot(row,col)
        # If the tile is filled, delete the rectangle and clear the reference
        else:
            self.c.delete(self.tiles[row][col])
            self.tiles[row][col] = None

    def updateAnnot(self, row, col,):
        idx = range(self.packetidx * self.packetSize, (self.packetidx + 1) * self.packetSize)
        self.annot[idx[row + col * self.rows]] = '0'


if __name__ == "__main__":

    app = labelXGui(target='BUETEEE18A',rows=12,cols=15)
    app.root.mainloop()
