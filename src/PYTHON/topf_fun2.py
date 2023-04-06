import topf

import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns


data = A          # load data
transformer = topf.PersistenceTransformer()  # prepare transformer
peaks = transformer.fit_transform(data)      # transform data into peaks

filtered_data = data[peaks[:, 1] > B]  # only keep high peaks