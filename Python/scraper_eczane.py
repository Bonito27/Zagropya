import requests 
from bs4 import BeautifulSoup 
import json 
import os 
import urllib3 

# sertifika hatalarını gizleme
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
url = "https://www.eczaneler.gen.tr/nobetci-isparta"

#chorome gibi gözükmek için header
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36"
}

def eczaneleri_cek():
    print(f"Bağlanılıyor: {url}")
    
    #siteye bağlanma
    try:
        # güvenlik sertifikası eski olsada kabul et
        response = requests.get(url, headers=headers, timeout=15, verify=False)
        
        if response.status_code != 200:
            print("Hata: Siteye erişilemedi.")
            return
    except Exception as e:
        print(f"Bağlantı Hatası: {e}")
        return

    soup = BeautifulSoup(response.content, "html.parser")
    
    #günü bulma filtre
    # sitede 3 günün hepsi aynı anda yükleniyor
    #bugünün tarihinde img var
    #img olanı filtreleme
    tab_linkleri = soup.find_all("a", class_="nav-link")
    aktif_tab_id = None
    
    for link in tab_linkleri:
        ikon = link.find("img")
        
        if ikon:
            href_degeri = link.get("href")
            if href_degeri:
                aktif_tab_id = href_degeri.replace("#", "") 
                print(f"Aktif Sekme Tespit Edildi: {aktif_tab_id}")
                break
    
    # ikon bulunmazsa nav bugun kullan
    if not aktif_tab_id:
        aktif_tab_id = "nav-bugun"

    # aramayı daraltma
    aktif_kutu = soup.find("div", id=aktif_tab_id)
    
    if not aktif_kutu:
        print("Hata: İçerik kutusu bulunamadı.")
        return

    # sadece aktif kutunun içindeki satırları al
    eczane_satirlari = aktif_kutu.find_all("div", class_="row")
    print(f"Bu sekmede {len(eczane_satirlari)} satır veri işleniyor.")
    
    eczane_listesi = []

    for satir in eczane_satirlari:
        try:
            # ilçe merkez filtresi
            ilce_etiketi = satir.find("span", class_="bg-info")
            if not ilce_etiketi: continue
                
            ilce = ilce_etiketi.text.strip()
            
            if "MERKEZ" not in ilce.upper():
                continue

            # verileri çekme
            
            link_etiketi = satir.find("a")
            if not link_etiketi: continue
            
            eczane_adi = link_etiketi.text.strip()
            detay_url = "https://www.eczaneler.gen.tr" + link_etiketi.get("href")

            sutunlar = satir.find_all("div", class_="col-lg-3")
            telefon = "Telefon Yok"
            if len(sutunlar) >= 2:
                telefon = sutunlar[1].text.strip()
            elif len(sutunlar) == 1:
                telefon = sutunlar[0].text.strip()
            adres_sutunu = satir.find("div", class_="col-lg-6")
            if adres_sutunu:
                raw_adres = adres_sutunu.text.strip()
                # adresden ilçe ismini temizle
                adres = raw_adres.replace(ilce, "").strip()
            else:
                adres = "Adres Belirtilmemiş"

            # listeye ekle
            veri = {
                "eczane_adi": eczane_adi,
                "telefon": telefon,
                "adres": adres,
                "ilce": ilce,
                "detay_url": detay_url
            }
            eczane_listesi.append(veri)

        except Exception as e:
            continue

    # json kaydetme
    klasor_yolu = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")
    os.makedirs(klasor_yolu, exist_ok=True)
    
    dosya_yolu = os.path.join(klasor_yolu, "nobetci_eczaneler.json")

    with open(dosya_yolu, "w", encoding="utf-8") as f:
        json.dump(eczane_listesi, f, ensure_ascii=False, indent=4)
        
    print("-" * 30)
    print(f"İşlem Tamam! {aktif_tab_id} sekmesindeki {len(eczane_listesi)} nöbetçi eczane kaydedildi.")
    print(f"Kayıt Yeri: {dosya_yolu}")

if __name__ == "__main__":
    eczaneleri_cek()