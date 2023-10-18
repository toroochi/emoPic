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
    "http://localhost:50482",
    "http://localhost:61098"
    "http://localhost:60414"
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
    if not firebase_admin._apps:
        cred = credentials.Certificate("/Users/kakinumayuusuke/Downloads/album-f0696-firebase-adminsdk-11isn-24684881fe.json") # ここ変えて
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
    text = clip.tokenize(["emotional","happy","sad","angry","anxious", "surprised"]).to(device)

    # 画像とテキストの類似度を計算
    with torch.no_grad():
        image_features = model.encode_image(image)
        text_features = model.encode_text(text)
        similarity = (100.0 * image_features @ text_features.T).softmax(dim=-1)

    similarity = similarity.to("cpu")
    #return(similarity)
    ret = int(similarity[0][0])
    print(similarity)
    return{
    "emotional":int(similarity[0][0]),
    "happy":int(similarity[0][1]),
    "sad":int(similarity[0][2]),
    "angry":int(similarity[0][3]),
    "anxious":int(similarity[0][4]),
    "surprised":int(similarity[0][5])
    }
    return {"item_id": item_id}