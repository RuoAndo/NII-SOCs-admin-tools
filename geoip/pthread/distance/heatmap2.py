import numpy as np
from matplotlib import pyplot as plt
import pandas as pd
import geopandas as gpd

import sys
args = sys.argv

# reading newly generated tmp
df = pd.read_csv('tmp')
print(df['lat'])

worldmap = gpd.read_file(gpd.datasets.get_path("naturalearth_lowres"))

# Creating axes and plotting world map
fig, ax = plt.subplots(figsize=(12, 6))
worldmap.plot(color="lightgrey", ax=ax)

threshold=100

# Plotting our Impact Energy data with a color map
x = df['lat']
y = df['lng']
z = df['count']
plt.scatter(x, y, s=20*z, c=z, alpha=0.6, vmin=0, vmax=threshold,
            cmap='autumn')
plt.colorbar(label='Server intensive rate')

# Creating axis limits and title
plt.xlim([-180, 180])
plt.ylim([-90, 90])

#first_year = df["Datetime"].min().strftime("%Y")
#last_year = df["Datetime"].max().strftime("%Y")
#plt.title("NASA: Fireballs Reported by Government Sensors\n" +     
#          str(first_year) + " - " + str(last_year))

plt.title(args[2])

plt.xlabel("Longitude")
plt.ylabel("Latitude")

imgstring = args[1] + "." + args[2] + ".png" 

plt.savefig(imgstring)
#plt.show()


