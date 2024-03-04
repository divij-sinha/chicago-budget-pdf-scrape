# %%
from docx.api import Document
from docx.table import Table
from docx.text.paragraph import Paragraph
import os
import pandas as pd


def return_df(table):
    table_data = []
    for row in table.rows:
        row_data = []
        for cell in row.cells:
            row_data.append(cell.text)
        table_data.append(row_data)
    df = pd.DataFrame(table_data)
    return df


def make_dirs(doc_name):
    os.makedirs(f"out/{doc_name}/project/", exist_ok=True)
    os.makedirs(f"out/{doc_name}/subrecipient/", exist_ok=True)
    os.makedirs(f"out/{doc_name}/subaward/", exist_ok=True)
    os.makedirs(f"out/{doc_name}/expenditure/", exist_ok=True)


def parse_doc(document):
    stage = 0
    last_text = ""
    last_df = None
    for obj in document.iter_inner_content():
        if isinstance(obj, Paragraph):
            cur_text = obj.text.strip()
            if cur_text == "Project Overview":
                stage = 1
                last_text = ""
            elif cur_text == "Subrecipients":
                stage = 2
                last_text = ""
            elif cur_text == "Subawards":
                stage = 3
                last_text = ""
            elif cur_text == "Expenditures":
                stage = 4
                last_text = ""
            if cur_text == "Report":
                stage = 5
            else:
                last_text += cur_text
        elif isinstance(obj, Table):
            if stage > 0 and stage < 5:
                df = return_df(obj)
                if last_text == "":
                    df = pd.concat([last_df.iloc[:-1], df])
                    df.loc[len(df)] = last_df.iloc[-1]
                    file_name = last_df.iloc[-1, 1].strip()
                    print(file_name)
                else:
                    df.loc[len(df)] = last_text.split(":", maxsplit=1)
                    file_name = (
                        last_text.split(d[stage]["title"])[-1].strip().replace("/", "-")
                    )
                file_name = f"out/{doc_name}/{d[stage]['folder']}/{file_name}.csv"
                df.to_csv(file_name)
                last_text = ""
                last_df = df
        else:
            print("DO NOT PRINT")


if __name__ == "__main__":
    doc_name = os.listdir("docx/")[0]
    document = Document(f"docx/{doc_name}")
    d = {
        1: {"folder": "project", "title": "Project Name:"},
        2: {"folder": "subrecipient", "title": "Subrecipient Name:"},
        3: {"folder": "subaward", "title": "Subward No:"},
        4: {"folder": "expenditure", "title": "Expenditure:"},
    }
    make_dirs(doc_name)
    parse_doc(document)
