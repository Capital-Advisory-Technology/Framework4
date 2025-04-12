import subprocess

# Define the path to the MT4 terminal executable
mt4_terminal_path = "C:/Program Files (x86)/MetaTrader4ICDev/terminal.exe"

# Command to run the forward test using the previously saved .set file
subprocess.run([mt4_terminal_path, "/config:tester_config.ini"])
