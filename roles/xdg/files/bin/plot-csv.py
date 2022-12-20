#!/usr/bin/env python3

import pandas as pd
import plotly.express as px
import sys

df = pd.read_csv(sys.argv[1])
fig = px.line(df, x = 'x', y = 'y', title='Plotly CSV Plot')
fig.show()
