# Paths to terminals
$terminals = @(
    "C:\Program Files (x86)\A Terminal 1\terminal.exe",
    "C:\Program Files (x86)\A Terminal 2\terminal.exe"
)

# Set priority level
$priorityClass = "RealTime" 

# Launch each application with the specified priority
foreach ($terminal in $terminals) {
    # Start the process
    $process = Start-Process -FilePath $terminal -PassThru

    # Set the priority of the process
    $process.PriorityClass = $priorityClass

    Write-Host "Launched $terminal with $priorityClass priority."
}