# Bengali.AI Computer Vision Challenge: Handwritten Bengali Grapheme Classification

This repo contains code to extend/replicate the dataset present in the Kaggle [Bengali.AI Handwritten Grapheme Classification](www.kaggle.com/c/bengaliai-cv19). For the dataset, codes, discussions and leaderboards, visit the Kaggle competition page. The paper describing the dataset, protocols and future directions can be found [here](https://arxiv.org/abs/2010.00170) or [here](https://github.com/BengaliAI/graphemePrepare/blob/master/paper/paper_10292020.pdf).

## Common Handwritten Graphemes in Context
#### Project Structure

```
.
- data
   -- scanned
   -- extracted
   -- error
   -- packed
- codes
- collection
   -- A4
   -- Letter
- logs
```

#### Basic Usage

1. Run `python ./data/extracted/purge.py` to clear extraction folders
2. Download and extract batch of scanned file .jpgs to `./data/scanned/<batchname>` 
3. `cd ./data/scanned` and run `python transcribeGui.py <batchname>`
4. After Roll/ID are transcribed execute `extract.m` on MATLAB. Specify `source` folder before executing. Replace `surfAlignGPU()` with `surfAlign` in the absence of GPU support. Set `disp=true` for `ocrForm(), surfAlign(), surfAlignGPU()` to validate extraction performance. For `surfAlign()` set `nonrigid=true`.
5. `cd ./data/error` and check for extraction failures.
6. `cd ./data/extracted` and check for label errors in sub-folders.
7. Run `python pack.py` which will create separate folders for each extracted `<batchname>` inside `./data/packed`.
8. `cd ./data/packed/` and run `python labelXGui.py <batchname>`. Select `overwriting` and `empty blobs` to be discarded and `Ctrl+S` to save. After you are done going through all of the packets, click the transfer button to remove errors from the packaged folder.

#### Dependencies
- MATLAB 2017b or higher

- MATLAB Computer Vision Toolbox

- Python 3.6.3 or higher

- Pillow == 4.2.1

#### Documentation
- Kaggle competition page [www.kaggle.com/c/bengaliai-cv19](www.kaggle.com/c/bengaliai-cv19)
- Dataset introduction [COCO-Grapheme](https://bengali.ai/wp-content/uploads/CV19-COCO-Grapheme.pdf)
