import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
#import japanize_matplotlib


import sys

args = sys.argv
 
def xy_plot(DF, X, Y):
    print(DF)
    df_x = DF[X]
    df_y = DF[Y]
    
    y_np = np.array(df_y)
    plt.figure(figsize=(8,10))
    plt.barh(range(len(df_x)), df_y, tick_label=df_x, align="center", color="magenta", height=0.8)
    for i, j in enumerate(y_np):
        plt.text(j, (i+0.5), str(int(j)), ha='left', va='top')
    #plt.title()
    plt.xlabel(y_name, fontsize=10)
    #if range_X:
    #    plt.xlim([range_X[0], range_X[1]])
    plt.grid(which="major", axis="x", color="black", alpha=0.8, linestyle="-", linewidth=1)
    plt.tight_layout()
    #plt.show()
    fig_name = os.path.splitext(os.path.basename(input_file))[0] + ".png"
    plt.savefig(fig_name)
    
    
def main():
    df = pd.read_csv(input_file, header=0, encoding="cp932") # 'utf-8' 'shift-jis' 'cp932'
    df_sorted = df.sort_values([y_name], ascending=True)
    xy_plot(df_sorted, x_name, y_name)


if __name__ == '__main__':
    input_file = args[1] 
    x_name = 'x'
    y_name = 'y'
    
    main()
