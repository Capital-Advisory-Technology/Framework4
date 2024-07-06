$srcDir = "C:\Framework4\*"
$terminalDir1 = "C:\Users\artur\AppData\Roaming\MetaQuotes\Terminal\4436C789DD6783682A87A8056812DF7E"
$terminalDir2 = "C:\Users\artur\AppData\Roaming\MetaQuotes\Terminal\24FF2268752179BE735F8A8A001BFE6E"

Copy-Item $srcDir -Destination $terminalDir1 -Container -Force -Recurse
Copy-Item $srcDir -Destination $terminalDir2 -Container -Force -Recurse
