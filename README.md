# Bengali.AI Computer Vision Challenge 2019
## Common Handwritten Graphemes in Context

#### Project Structure

```
.
-data
--scanned
--extracted
--error
-codes
-collection
--A4
--Letter
-logs
```

#### Basic Usage

1. Run `python ./data/extracted/purge.py` to clear extraction folders
2. Download and extract batch of scanned file .jpgs to `./data/scanned/<batchname>` 
3. `cd ./data/scanned` and run `python renameGui.py <batchname>`
4. After files are renamed execute `extract.m` on MATLAB. Specify target folder before executing.
5. `cd ./data/error` and check for extraction failures.
6. `cd ./data/extracted` and check for label errors in folders.
