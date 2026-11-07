from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

@app.get("/health")
def health_check():
    return {"status": "ok"}

class SummaryRequest(BaseModel):
    text: str

@app.post("/summaries")
def generate_summary(request: SummaryRequest):
    text = request.text.strip()
    if not text:
        raise HTTPException(status_code=400, detail="Text is empty")
    return {"summary": "This is a summary of the text"}