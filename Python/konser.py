import requests  
from bs4 import BeautifulSoup  
import json  
import os 



base_url = "https://www.bubilet.com.tr" 
url = "https://www.bubilet.com.tr/isparta"

# # siteye robot olmadığımızı göstermek için header bilgisi
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36"
}

def veri_cek_final():
    print(f"Sunucu isteği gönderiliyor: {url}")
    
    #SİTEYE BAĞLANMA
    response = requests.get(url, headers=headers)
    
    
    if response.status_code != 200:
        print("Hata: Siteye bağlanılamadı.")
        return

    # gelen hamveriyi işlenebilir HTML yapısına çevirme 
    soup = BeautifulSoup(response.content, "html.parser")
    
    tarih_etiketleri = soup.find_all("p", class_="mt-0.5 text-xs text-gray-500")
    
    print(f"Bulunan Etkinlik Sayısı: {len(tarih_etiketleri)}")
    
    sonuc_listesi = []

    for tarih_tag in tarih_etiketleri:
        try:
            # verileri toplama
            
            #tarih verisi
            tarih = tarih_tag.text.strip()
            
            yazi_kutusu = tarih_tag.parent
            ana_kart = yazi_kutusu.parent.parent 

            # mekan verisi
            # yazı kutusunun içinde 'truncate' sınıfına sahip olan alan mekan bilgisidir.
            mekan_tag = yazi_kutusu.find("span", class_="truncate")
            mekan = mekan_tag.text.strip() if mekan_tag else ""

            # fiyat Verisi
            fiyat_tag = ana_kart.find("span", class_="tracking-tight")
            raw_fiyat_text = "" 
            fiyat = "Fiyat Yok"

            if fiyat_tag:
                raw_fiyat_text = fiyat_tag.text.strip()
                # veri sayı ise sonuna tl ekleniyor
                if raw_fiyat_text.isdigit():
                    fiyat = f"{raw_fiyat_text} TL"
                else:
                    fiyat = raw_fiyat_text

            # resim verisi
            img_tag = ana_kart.find("img")
            resim_url = "https://via.placeholder.com/150" # bulunmazsa resmi

            if img_tag:
                ham_link = img_tag.get("data-src") or img_tag.get("src")
                
                if ham_link:
                    #link relative görsel ise başına site adresi ekleniyor
                    if ham_link.startswith("/"):
                        resim_url = base_url + ham_link
                    else:
                        resim_url = ham_link

            # sanatçının isminin sonundaki çıkan fiyatı silme
            
            ham_metin = yazi_kutusu.text
            
            temiz_isim = ham_metin.replace(tarih, "").replace(mekan, "")
            
            if raw_fiyat_text:
                temiz_isim = temiz_isim.replace(raw_fiyat_text, "")
            
            temiz_isim = temiz_isim.replace("TL", "").replace("tl", "").replace("₺", "")
            isim = " ".join(temiz_isim.split()) 

            # listeyi oluşturma
            veri = {
                "sanatci": isim,
                "tarih": tarih,
                "mekan": mekan,
                "price": fiyat,
                "image": resim_url
            }
            sonuc_listesi.append(veri)
            
        except AttributeError:
            # yapıda beklenmeyen bozukluk varsa işlemi geçme
            continue

    # json olarak kaydetme
    #assets klasörünü bul yoksa oluştur
    klasor_yolu = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")
    os.makedirs(klasor_yolu, exist_ok=True)
    
    dosya_yolu = os.path.join(klasor_yolu, "konserler.json")

    #veriyi türkçe formatta kaydetme
    with open(dosya_yolu, "w", encoding="utf-8") as f:
        json.dump(sonuc_listesi, f, ensure_ascii=False, indent=4)
    
    print("-" * 30)
    print(f"Başarılı! {len(sonuc_listesi)} etkinlik kaydedildi.")
    print(f"Kayıt Yeri: {dosya_yolu}")

if __name__ == "__main__":
    veri_cek_final()