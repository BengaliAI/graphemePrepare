import tkinter as tk
from PIL import Image, ImageTk

# Set number of rows and columns
ROWS = 5
COLS = 5

# Create a grid of None to store the references to the tiles
tiles = [[None for _ in range(COLS)] for _ in range(ROWS)]

def callback(event):
    # Get rectangle diameters
    col_width = c.winfo_width()/COLS
    row_height = c.winfo_height()/ROWS
    # Calculate column and row number
    col = int(event.x//col_width)
    row = int(event.y//row_height)
    print(event.x,event.y)
    # If the tile is not filled, create a rectangle
    if not tiles[row][col]:
        tiles[row][col] = c.create_rectangle(col*col_width, row*row_height, (col+1)*col_width, (row+1)*row_height, fill="black")
    # If the tile is filled, delete the rectangle and clear the reference
    else:
        c.delete(tiles[row][col])
        tiles[row][col] = None

# Create the window, a canvas and the mouse click event binding
root = tk.Tk()
c = tk.Canvas(root, width=512, height=512, borderwidth=5, background='white')
path = 'M:/graphemePrepare/data/packed/BUETEEE18A/ং_BUETEEE18A_scan0048.png'
img = ImageTk.PhotoImage(Image.open(path).resize((100,50)))
c.pack()
c.create_image(0,0,image=img,anchor='nw')
c.create_image(101,0,image=img,anchor='nw')
c.create_image(202,0,image=img,anchor='nw')
c.create_image(303,0,image=img,anchor='nw')
c.bind("<Button-1>", callback)

root.mainloop()