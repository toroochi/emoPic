from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import torch
import clip
from PIL import Image
import json

import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage
import io
app = FastAPI()

origins = [
    "http://localhost.tiangolo.com",
    "https://localhost.tiangolo.com",
    "http://localhost",
    "http://localhost:8080",
    "http://localhost:50482"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/items/{item_id}")
async def read_item(item_id:str):


    # firebase の設定

    cred = credentials.Certificate("/Users/yamaokana/Documents/album-f0696-firebase-adminsdk-11isn-ebf6feb5ed.json") # ここ変えて
    default_app =firebase_admin.initialize_app(cred)

    bucket = storage.bucket("album-f0696.appspot.com")

    # これを受け取る
    file_name = "image/"
    file_name += item_id

    blob = bucket.blob(file_name)

    byte_io = io.BytesIO(blob.download_as_bytes())
    pil = Image.open(byte_io)

    # デバイスの指定
    device = "cuda" if torch.cuda.is_available() else "cpu"

    # CLIPモデルの読み込み
    model, preprocess = clip.load("ViT-B/32", device=device)

    # 画像の読み込みと前処理
    image = preprocess(pil).unsqueeze(0).to(device)

    # テキストの読み込みと前処理
    text = clip.tokenize(["chiken","milk","women"]).to(device)

    # 画像とテキストの類似度を計算
    with torch.no_grad():
        image_features = model.encode_image(image)
        text_features = model.encode_text(text)
        similarity = (100.0 * image_features @ text_features.T).softmax(dim=-1)

    similarity = similarity.to("cpu")
    #return(similarity)
    ret = int(similarity[0][0])
    return{"chiken":int(similarity[0][0]),"milk":int(similarity[0][1]),"women":int(similarity[0][2])}
    return {"item_id": item_id}