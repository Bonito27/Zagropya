import time
import os

try:
    import scraper_etkinlik
    import scraper_eczane
    import scraper_duyuru 
except ImportError as e:
    print(f"dosyalar bulunamadı\nHata: {e}")
    exit()

def tum_sistemi_calistir():
    
    baslangic_zamani = time.time()

    # etkinlikler   
    try:
        print("etkinlik verileri çekiliyor")
        # scraper_etkinlik dosyasındaki fonksiyonu çalıştır
        scraper_etkinlik.veri_cek_final() 
        print("etkinlikler tamamlandı.\n")
    except Exception as e:
        print(f"veri çekiminde hata oluştu {e}\n")

    time.sleep(1) # karışıklık olmasın diye bekleme

    # eczaneler
    try:
        print("nöbetçi eczaneler çekiliyor")
        # scraper_eczane dosyasındaki fonksiyonu çalıştır
        scraper_eczane.eczaneleri_cek()
        print("eczaneler çekildi.\n")
    except Exception as e:
        print(f"veri çekiminde hata oluştu {e}\n")

    time.sleep(1)

    # duyurular
    try:
        print("son duyuru çekiliyor")
        # scraper_duyuru dosyasındaki fonksiyonu çalıştır
        scraper_duyuru.son_duyuruyu_cek()
        print("duyuru alındı.\n")
    except Exception as e:
        print(f"veri çekiminde hata oluştu {e}\n")

    # bitis
    bitis_zamani = time.time()
    gecen_sure = round(bitis_zamani - baslangic_zamani, 2)

    print("==========================================")
    print(f"tüm işlemler tamamlandı ({gecen_sure} saniye)")
    print(f"veriler assets'e kaydedildi.")
    print("==========================================")

if __name__ == "__main__":
    tum_sistemi_calistir()