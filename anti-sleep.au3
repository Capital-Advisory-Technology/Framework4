#include <Date.au3>
; Set the time interval (in seconds)
Global $n = 60$iRunCount
Global $iRunCount = 0

; Infinite loop
While True
    ; Move mouse to (0, 0)
    MouseMove(0, 0, 10)

    ; Generate random X and Y positions
    Local $randomX = Random(0, @DesktopWidth, 1)
    Local $randomY = Random(0, @DesktopHeight, 1)

    ; Move mouse to the random position
    MouseMove($randomX, $randomY, 10)

    ; Wait for n minutes
    Sleep($n * 1000) ; Sleep function takes milliseconds, so convert minutes to milliseconds
	
	$iRunCount+= 1
	ConsoleWrite("Run Count: " & $iRunCount & " Datetime: " & _NowCalc() & @CRLF)
WEnd