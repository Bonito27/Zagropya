import requests 
from bs4 import BeautifulSoup 
import json 
import os 
import re 

# scratching yapılacak site
url = "https://www.gazete32.com.tr/isparta-sehir-ici-otobus-seferleri/"
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36"
}

def otobus_saatlerini_cek():
    print(f"Bağlanılıyor: {url}")
    
    # siteden request isteme
    response = requests.get(url, headers=headers)
    
    if response.status_code != 200:
        print("Hata: Siteye erişilemedi.")
        return

    # gelen veriyi işlenebilir hale getirme
    soup = BeautifulSoup(response.content, "html.parser")
    
    # sayfadaki açılıp kapanabilen butonları bulma
    butonlar = soup.find_all("button", class_="accordion")
    print(f"Toplam {len(butonlar)} hat bulundu.")
    
    otobus_listesi = []

    for buton in butonlar:
        try:
            ham_isim = buton.text.strip()
            
            # hat ismini temizleme
            # sitedeki özel - işaretlerini standart - çevirme
            ham_isim = ham_isim.replace("–", "-").replace("—", "-")
            
            # -'den bölüp sadece hat ismini alma 
            hat_adi = ham_isim.split("-")[0].strip()
            
            # saatleri bulma
            panel = buton.find_next_sibling("div", class_="panel")
            if not panel: continue 

            panel_metni = panel.text
            bulunan_saatler = re.findall(r'\d{2}[:.]\d{2}', panel_metni)
            
            temiz_saatler = []
            for saat in bulunan_saatler:
                saat = saat.replace(".", ":")
                temiz_saatler.append(saat)

            if not temiz_saatler: continue

            # listeye ekleme
            veri = {
                "hat_adi": hat_adi,
                "saatler": temiz_saatler
            }
            otobus_listesi.append(veri)

        except Exception as e:
            continue

    # json olarak kaydetme
    # assetsi bulma
    klasor_yolu = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")
    os.makedirs(klasor_yolu, exist_ok=True)
    
    dosya_yolu = os.path.join(klasor_yolu, "otobus_saatleri.json")

    # veriyi türkçe karaktere çevirme
    with open(dosya_yolu, "w", encoding="utf-8") as f:
        json.dump(otobus_listesi, f, ensure_ascii=False, indent=4)
        
    print("-" * 30)
    print(f"Tamamlandı! '{hat_adi}' formatında {len(otobus_listesi)} hat kaydedildi.")

if __name__ == "__main__":
    otobus_saatlerini_cek()