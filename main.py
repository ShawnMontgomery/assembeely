#!/usr/bin/env python
# coding: utf-8

# In[132]:


#!/usr/bin/env python3

import pandas as pd
import json


# In[129]:


def getRowForDf(filePrefix):
    sam_df = pd.read_table(filePrefix + ".sam.stats")
    
    mean_cov = sam_df["coverage"].mean(axis=0)
    meanDepth = sam_df["meandepth"].mean(axis=0)

    jsonFile = open(filePrefix + ".ass.stats", "r")

    ass_json = json.loads(jsonFile.read())

    jsonFile.close()
    
    with open(filePrefix + ".rate.stats") as f:
        alignRate = f.read()
  
    ass_parents = ["Contig Stats", "Scaffold Stats"]
    ass_children = ["L50", "N50"]

    ass_arr = []

    for parent in ass_parents:
        for child in ass_children:
            ass_arr.append(ass_json[parent][child])
            
    
    ass_arr.append(mean_cov)
    ass_arr.append(meanDepth)
    ass_arr.append(alignRate)
    
    return ass_arr


# In[138]:


errRates = ["0.01", "0.05", "0.1"]
files = ["bowRefFast", "bowRefSlow", "bowScafFast", "bowScafSlow"]
seqLabel = ["Reference", "Reference", "Scaffold", "Scaffold"]
sensLabel = ["Low", "High", "Low", "High"]
    
cols = ["Sequence", "MSA Sensitivity", "Simulated Read Error Rate", "Contig Stats L50", "Contig Stats N50", "Scaffold Stats L50", "Scaffold Stats N50", 'Mean Coverage', 'Mean Depth', 'Alignment Rate']

df = pd.DataFrame(columns = cols)
df['Mean Coverage'] = df['Mean Coverage'].astype(float)
df['Mean Depth'] = df['Mean Depth'].astype(float)
# df['Alignment Rate'] = df['Alignment Rate'].astype(float)

for errRate in errRates:
    for i in range(len(files)):
        file = files[i]
        colData = getRowForDf("err" + errRate + "/" + file)
        row = [seqLabel[i], sensLabel[i], errRate]
        row.extend(colData)
        df.loc[len(df)] = row

df = df.set_index(['Sequence', 'MSA Sensitivity', 'Simulated Read Error Rate']).sort_index()
df.to_csv('results.csv')


# In[ ]:





# In[ ]:




