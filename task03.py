import pandas as pd
filename = "case03_input_file..xlsx"
df = pd.read_excel(filename, header=None)
rows = df.iloc[0:9]
current_table = 0
results_df = pd.DataFrame(data={"Filename": [filename], "Region": [""], "Partner": [""], "Range": [""], "Value": [""]})
while True:
    for i in range(1,9): #Проход по всем столбцам
        if not rows.empty:
            if not pd.isna(rows.iat[0, 0]):
                selected_data = rows.iloc[2:9, [0, i]].values.tolist()
                region = rows.iat[0, 0]
                value=rows.iloc[2:9, i].values.tolist()
                if(not pd.isna(value[0])):
                    csv_range=rows.iloc[2:9, 0].values.tolist()
                    tmp_df = pd.DataFrame()
                    tmp_df["Range"]=csv_range
                    tmp_df["Value"]=value
                    tmp_df["Region"] = region
                    tmp_df["Filename"] = filename
                    tmp_df["Partner"] = rows.iat[1, i]
                    results_df = pd.concat([results_df, tmp_df], ignore_index=True) #Соединяет значения текущей таблицы с общими
        else:
            break
    current_table += 10
    rows = df.iloc[current_table:current_table + 9] #следующая таблица
    if rows.empty:
        break
results_df = results_df.iloc[1:]
results_df.to_csv("output.csv", index=False)
