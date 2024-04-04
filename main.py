from pypdf import PdfReader
from datetime import date, timedelta
from urllib.request import urlopen
import json

today = date.today()

def tpn_scraper():
    url = "https://lawiny.topr.pl/"
    page = urlopen(url)
    html_bytes = page.read()
    html = html_bytes.decode("utf-8")
    print(html)
def extract_description_from_pdf():
    reader = PdfReader(f'./archive/{today}_avalanche.pdf')
    page = reader.pages[0]
    text = page.extract_text()
    do_write = False
    do_write_danger = False
    global text_to_write
    text_to_write = ""
    global danger_level
    with open("tmp.txt", "w") as f:
        f.write(text)

    with open("tmp.txt", "r") as f:
       for l in f:
            l = l.strip()
            if l[0:19] == "Stopień zagrożenia:":
                danger_level = l[20::]
            if l == "TURYSTO, TATERNIKU, NARCIARZU!":
                do_write = False
            if do_write:
                text_to_write += l
            if l == "Informacje dodatkowe:":
                do_write = True


def write_to_json():
    try:
        with open("exact_description.json", "r") as f:
            existing_data = json.load(f)
    except FileNotFoundError:
        existing_data = {"data": []}

    existing_data["data"].append({"date": f'{today}', "description": f'{text_to_write}', "danger_level": f'{danger_level}'})

    with open("exact_description.json", "w") as f:
        json.dump(existing_data, f, ensure_ascii=False, indent=4)

# tpn_scraper()
extract_description_from_pdf()
write_to_json()