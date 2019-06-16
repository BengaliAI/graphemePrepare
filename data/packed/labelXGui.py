import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk
import os
import sys
import csv
import math
import shutil

### On windows get display size
try:
    from win32api import GetSystemMetrics

    winWidth = GetSystemMetrics(0)
    winHeight = GetSystemMetrics(1)
except:
    winWidth = 1920
    winHeight = 1080


class labelXGui(object):
    def __init__(self, target, rows, cols, debug=False, fontsize=11, startidx=None):
        """
        creates Gui object for annotation
        :param target: target filename
        :param rows: number of rows to display
        :param cols: number of columns to display
        :param debug: print debug options
        :param fontsize: ground truth display fontsize
        :param startidx: starting packet
        """
        self.errorPath = os.path.join('..','error')
        self.rows = rows
        self.cols = cols
        self.debug = debug
        self.fontsize = fontsize
        self.packetSize = rows * cols
        if self.debug:
            print('Packet Size: ',self.packetSize)
        self.root = tk.Tk()
        self.target = target
        self.targetConf = target + '.conf'
        self.packed = os.listdir(target)
        self.numPack = math.ceil(len(self.packed) / self.packetSize)
        self.chkConf()

        ## override for debugging
        if startidx is not None:
            self.packetidx = startidx

        self.c = self.frameInit()
        self.showPacket(self.packetidx)
        self.c.bind("<Button-1>", self.onClickLeft)
        self.c.bind("<Alt-Button-1>", self.onClickRight)
        self.c.bind("<Alt-Button-3>", self.altClickRight)
        self.c.bind("<Button-3>", self.onClickRight)
        self.root.bind("<Alt-Right>", self.nextPacket)
        self.root.bind("<Alt-Left>", self.prevPacket)
        self.root.bind("<Control-Key-s>", self.confSave)

    def __call__(self):
        self.root.mainloop()

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
                    if index == 0:
                        self.packetidx = 0
                    else:
                        self.packetidx = index // self.packetSize - 1
                except ValueError:
                    self.packetidx = self.numPack - 1
        else:
            self.header = ['filename', 'label', 'pass']
            self.annot = ['1'] * len(self.packed)
            self.annotPass = ['0'] * len(self.packed)
            self.confSave()
            self.metaList = []
            self.packetidx = 0

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
        if self.debug:
            print('Screen Resolution ',winWidth,winHeight)
        self.root.title('Bengali.AI Common Graphemes in Context')
        self.root.iconbitmap(os.path.join('..','..','favicon.ico'))
        self.container = tk.LabelFrame(self.root, font=("Roboto"), text='BATCHNAME: '+ self.target)
        self.container.pack(fill="both", expand="yes")
        self.label = tk.Label(self.container, font=("Roboto", 9), text='LMouse: Mark Grapheme Error;    RMouse: Split Groundtruth;    Alt+RMouse: Hide Groundtruth;    Alt+RArrow: Next Page;    Alt+LArrow: Prev Page;   Ctrl+S: Save;')
        self.label.pack(side='left')
        self.packet = tk.StringVar()
        self.packetDisp = tk.Label(self.container, font=("Roboto"), textvariable=self.packet)
        self.packetDisp.pack(side='right')
        self.packet.set(str(self.packetidx) + '/' + str(self.numPack-1))

        ### add buttons
        self.save = tk.Button(self.container, font=("Roboto"), text="SAVE", command=self.confSave)
        self.save.pack(side='right')
        self.next = tk.Button(self.container, font=("Roboto"), text="NEXT", command=self.nextPacket)
        self.next.pack(side='right')
        self.prev = tk.Button(self.container, font=("Roboto"), text="PREV", command=self.prevPacket)
        self.prev.pack(side='right')
        self.transfer = tk.Button(self.container, font=("Roboto"), text="TRANSFER LABEL ERRORS", command=self.transfer)
        self.transfer.pack(side='right')

        ### create grid
        self.gridHeight = math.ceil(winHeight * .8)
        self.gridWidth = math.ceil(winWidth * .8)
        if self.debug:
            print('Canvas Size',self.gridWidth,self.gridHeight)
        self.imgWidth = math.floor(self.gridWidth / self.cols)
        self.imgHeight = math.floor(self.gridHeight / self.rows)
        self.anchors = [(cl, rw) for cl in range(0, self.gridWidth, self.imgWidth)
                        for rw in range(0, self.gridHeight, self.imgHeight) if (rw+self.imgHeight/2<self.gridHeight and
                                                                                cl+self.imgWidth/2<self.gridWidth)]
        if self.debug:
            print('Anchors ',self.anchors)
        c = tk.Canvas(self.root, width=self.gridWidth,
                           height=self.gridHeight, borderwidth=0, background='white')
        c.pack()
        return c

    def transfer(self):
        if '0' in self.annotPass:
            messagebox.showerror("Error", "Cannot transfer graphemes until label checking is complete")
        else:
            answer = messagebox.askokcancel("Confirmation", "Confirm Transfer")
            if answer:
                self.root.destroy()
                errorList = [each for i,each in enumerate(self.packed) if self.annot[i] == '0']
                for each in errorList:
                    shutil.move(os.path.join(os.getcwd(),self.target,each),os.path.join(self.errorPath,each))
                print("Transfer Complete")
                ### update conf
                self.packed = [each for i,each in enumerate(self.packed) if self.annot[i] == '1']
                self.annotPass = [each for i, each in enumerate(self.annotPass) if self.annot[i] == '1']
                self.annot = [each for i, each in enumerate(self.annot) if self.annot[i] == '1']
                self.confSave()

    def nextPacket(self,event=None):
        self.packetidx += 1
        if self.packetidx > self.numPack-1:
            self.packetidx = self.numPack-1
        self.packet.set(str(self.packetidx) + '/' + str(self.numPack - 1))
        self.bufferFlush()
        self.showPacket(self.packetidx)
        # self.confSave()

    def prevPacket(self,event=None):
        self.packetidx -= 1
        if self.packetidx < 0:
            self.packetidx = 0
        self.packet.set(str(self.packetidx) + '/' + str(self.numPack - 1))
        self.bufferFlush()
        self.showPacket(self.packetidx)
        # self.confSave()

    def bufferFlush(self):
        """
        Flushes the Display Buffers
        """
        for rw in self.tiles:
            for cl in rw:
                self.c.delete(cl)
        for rw in self.gtCheatBuff:
            for cl in rw:
                self.c.delete(cl)
        for each in self.imgBuff:
            self.c.delete(each)
        for each in self.txtBuff:
            self.c.delete(each)

    def bufferInit(self):
        """
        Initializes the Display Buffers
        """
        self.tiles = [[None for _ in range(self.cols)] for _ in range(self.rows)]
        self.gtCheat = [[None for _ in range(self.cols)] for _ in range(self.rows)]
        self.gtCheatBuff = [[None for _ in range(self.cols)] for _ in range(self.rows)]
        self.PILbuffer = []
        self.imgBuff = []
        self.txtBuff = []

    def showPacket(self,packetidx):
        """
        Displays packet for current packetidx and updates annotPass
        """
        self.bufferInit()
        idx = range(packetidx * self.packetSize, (packetidx + 1) * self.packetSize)
        for enum, each in enumerate(zip(idx, self.anchors)):
            i,anchor = each
            try:
                path = os.path.join(os.getcwd(), self.target, self.packed[i])
            except IndexError:
                break
            self.PILbuffer.append(ImageTk.PhotoImage(Image.open(path).resize((self.imgWidth, self.imgHeight))))
            self.imgBuff.append(self.c.create_image(anchor, image=self.PILbuffer[-1], anchor='nw'))

            col = enum // self.rows
            row = enum % self.rows

            if self.annot[i] == '0':
                self.tiles[row][col] = self.c.create_oval(col * self.imgWidth, row * self.imgHeight,
                                                          (col + 1) * self.imgWidth,
                                                          (row + 1) * self.imgHeight,
                                                          stipple='gray50', width=2)
            display_text = self.packed[i].split('_')[0]
            self.gtCheat[row][col] = ''.join([each+'+' for each in display_text[:-1]]+[display_text[-1]])
            self.txtBuff.append(self.c.create_text(anchor[0]+3,anchor[1]+5,
                                                   text=display_text,
                                                   font=("Purisa", self.fontsize), anchor='nw'))
            self.annotPass[i] = '1'

    def onClickRight(self,event):
        col = int(event.x // self.imgWidth)
        row = int(event.y // self.imgHeight)
        # print(row, col)
        if not self.gtCheatBuff[row][col]:
            self.gtCheatBuff[row][col] = self.c.create_text(event.x,event.y,text=self.gtCheat[row][col],
                                                                font=("Purisa", self.fontsize), anchor='w')
        else:
            self.c.delete(self.gtCheatBuff[row][col])
            self.gtCheatBuff[row][col] = None
	
    def altClickRight(self,event):
        col = int(event.x // self.imgWidth)
        row = int(event.y // self.imgHeight)
        
        idx = range(self.packetidx * self.packetSize, (self.packetidx + 1) * self.packetSize)
        buffIdx = row + col * self.rows
        anchor = self.anchors[buffIdx]
		
        if not self.txtBuff[buffIdx]:
            self.txtBuff[buffIdx] = self.c.create_text(anchor[0]+3,anchor[1]+5,
                                                   text= self.packed[idx[row + col * self.rows]].split('_')[0],
                                                   font=("Purisa", self.fontsize), anchor='nw')
        else:
            self.c.delete(self.txtBuff[buffIdx])
            self.txtBuff[buffIdx] = None

    def onClickLeft(self,event):
        col = int(event.x // self.imgWidth)
        row = int(event.y // self.imgHeight)
        if self.debug:
            print('Row:',row,'Col',col)
        if not self.tiles[row][col]:
            self.tiles[row][col] = self.c.create_oval(col * self.imgWidth, row * self.imgHeight,
                                                      (col + 1) * self.imgWidth,
                                                      (row + 1) * self.imgHeight,
                                                      stipple='gray50', width=2)
            self.updateAnnot(row,col,'0')
        # If the tile is filled, delete the rectangle and clear the reference
        else:
            self.c.delete(self.tiles[row][col])
            self.tiles[row][col] = None
            self.updateAnnot(row, col, '1')

    def updateAnnot(self, row, col, label='0'):
        idx = range(self.packetidx * self.packetSize, (self.packetidx + 1) * self.packetSize)
        try:
            self.annot[idx[row + col * self.rows]] = label
        except IndexError:
            print('No grapheme')


if __name__ == "__main__":

    ### override for debugging
    # app = labelXGui(target='BUETEEE18A',rows=12,cols=15)

    if len(sys.argv)<2:
        print('ERROR: Please Specify Batchname Argument `python labelXGui.py BUETEEE18A`')
        exit()
    else:
        app = labelXGui(target=sys.argv[1],rows=15, cols=15, fontsize=11, debug=True)
        app()
