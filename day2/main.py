from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from groq import Groq, APITimeoutError, APIConnectionError

app = FastAPI()
client = Groq(timeout=20.0, max_retries=0)

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

    try:
        response = client.chat.completions.create(
            model="openai/gpt-oss-20b", 
            messages=[
                {"role":"system","content":"입력된 메모를 한국어 한 문장으로 요약하세요. 요약문만 반환하세요."},
                {"role":"user","content":text}])
        return {"summary": response.choices[0].message.content}
    except APITimeoutError:
        raise HTTPException(status_code=504, detail="요약 응답 시간이 초과되었습니다.")
    except APIConnectionError:
        raise HTTPException(status_code=502, detail="요약 서비스에 연결할 수 없습니다.")