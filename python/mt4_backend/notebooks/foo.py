import pandas as pd

# Example DataFrame
data = {'loss': [0, 1, 1, 0, 0, 1, 0]}
df = pd.DataFrame(data)

# Initialize variables to track streaks
lose_streaks = []
current_streak = 0
previous_loss = 0

# Iterate over the loss column to calculate streaks
for i, loss in enumerate(df['loss']):
    if loss == 1:
        # Accumulate losses in the streak
        current_streak += 1
    else:
        # If the previous loss was part of a streak, append it
        if current_streak > 0:
            lose_streaks.append(current_streak)
            current_streak = 0
        # If there are consecutive wins, append 0
        if previous_loss == 0:
            lose_streaks.append(0)

    # Update the previous loss to track consecutive wins
    previous_loss = loss

# If there was a streak at the end, append it
if current_streak > 0:
    lose_streaks.append(current_streak)

print(lose_streaks)
