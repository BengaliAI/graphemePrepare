import tkinter as tk
from PIL import Image, ImageTk
import os
import sys

### Initialize counter list and roi in scan
idx = 0
root = tk.Tk()
target = os.path.join('scanned','BUETEEE18C')
#target = os.path.join('scanned',sys.argv[1])
scanList = os.listdir(target)
roi = (0,0,1900,500)
entryList = ['']*len(scanList)

### display filename and entry panel
container = tk.LabelFrame(root, text='Bengali.AI Common Graphemes in Context')
container.pack(fill="both", expand="yes")
filename = tk.StringVar()
label = tk.Label(container, textvariable=filename )
label.pack(side='left')
filename.set('Filename: '+scanList[idx])

dispText = tk.StringVar()
studentid = tk.Entry(container, text='Student ID/Roll', bd =5, width=50, textvariable=dispText)
studentid.pack(side='left')
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

#frame = tk.Frame(root, width=30, height=30)
root.bind('<Alt-Left>', leftKey)
root.bind('<Alt-Right>', rightKey)
root.bind('<Return>', rightKey)
root.mainloop()