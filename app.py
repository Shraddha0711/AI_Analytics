import google.generativeai as genai
import os
from dotenv import load_dotenv
from prompt import Prompt
import chainlit as cl
import mysql.connector
import pandas as pd
# from prettytable import PrettyTable 
import plotly.graph_objects as go



load_dotenv()
genai.configure(api_key=os.getenv('gemini_api_key'))
model = genai.GenerativeModel('gemini-pro',generation_config={'temperature':0.4})

prompt1 = [
        {'role': 'user', 
            'parts': [f'{Prompt}']
            },
        {'role': 'model', 
            'parts': ["Understood"]
            }
]
chat = model.start_chat(history=prompt1 )    


def genai2(input_message):        
    '''
    "generationConfig": {
                "temperature": 0.4,
                "topP":0.5,
                "topK": 3,
                "candidateCount": 1,
                "maxOutputTokens": 2600,
            }
    '''
    response = chat.send_message(input_message)
    return response.text


def query_database(query):
        conn = mysql.connector.connect(
                host="localhost",
                user="root",
                password="root",
                database="new_data"
        )
                
        cur = conn.cursor()
        cur.execute(query)
        rows = cur.fetchall()
        columns = [description[0] for description in cur.description] if cur.description else []
        conn.close()
        return rows, columns



@cl.on_message
async def main(message: cl.Message):
    await cl.Avatar(
            name="ChatBot",
            url="https://pics.craiyon.com/2023-11-16/LFXsTXnkR9mZ9vK5OS11bQ.webp",
        ).send()
    res=genai2(message.content)
    if "```sql" in res:
        query = (((res.split("```"))[1]).removeprefix("sql\n")).removesuffix("\n")
        summary = (((res.split("```"))[2]).removeprefix("sql\n")).removesuffix("\n")
        rows,columns=query_database(query)
        df=pd.DataFrame(rows,columns=columns)   
        # with pd.option_context('display.max_rows', None, 'display.max_columns', None,'display.width', 1000):
            # myTable = PrettyTable(columns) 
            # for i in rows:
            #     myTable.add_row(i)


        fig = go.Figure(data=[go.Table(
            header=dict(values=list(df.columns)),
            cells=dict(values=[df[i] for i in df.columns])
            )],layout=dict(autosize=True))
        fig.update_layout(paper_bgcolor='#424242')

        elements = [cl.Plotly(name="chart", figure=fig, display="inline")]

        await cl.Message(content=f"**Count : {len(rows)}**{summary}", elements=elements,author="ChatBot").send()
        # await cl.Message(content=query).send()

        csv_content = df.to_csv(sep=',', index=False).encode('utf-8')
        elements = [
        cl.File(
        name="data.csv",
        content=csv_content,
        display="inline",
        ),
        ]

        await cl.Message(content=f"**Query**\n{query}.\n\n**Download the data as CSV file**", elements=elements,author="ChatBot").send()


    else:
        await cl.Message(
            content=res
            ,author="ChatBot"
        ).send()
