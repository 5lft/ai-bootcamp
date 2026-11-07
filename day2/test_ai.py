from groq import Groq


client = Groq()

response = client.chat.completions.create(
        model="openai/gpt-oss-20b", 
        messages=[
            {"role":"system","content":"입력된 메모를 한국어 한 문장으로 요약하세요. 요약문만 반환하세요."},
            {"role":"user","content":"오늘 FastAPI로 서버를 만들었다. 빈 메모를 보내면 오류를 반환하도록 구현했고 브라우저에서 테스트했다."}])

print(response.choices[0].message.content)
