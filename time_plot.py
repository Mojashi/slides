import pandas as pd
from matplotlib.font_manager import FontProperties
from matplotlib import pyplot as plt

if __name__ == "__main__":
    d = pd.read_csv("time.csv", index_col=0)

    prop = FontProperties()
    prop.set_file('misc/BIZUDGothic-Regular.ttf')

    fig = plt.figure()
    ax = d.plot.line(logy=True, style=['r+', 'b+', 'g+', 'k+'])
    ax.set_ylabel("elapsed(ms)")
    ax.set_xlabel("最終的なトランスデューサの状態数",  fontproperties=prop)
    ax.get_figure().savefig("assets/time.png", dpi=199)
