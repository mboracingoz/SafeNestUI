# 📱 SafeNest UI — V1 MVP Tamamlanma Raporu ve Rehberi

Bu proje, mobil oyunlardaki (ve PC'deki) "Çentik (Notch)" ve "Görev Çubuğu" gibi ekran ölü bölgelerine UI elemanlarının taşmasını engellemek için geliştirilmiş hafif bir Godot eklentisidir.

## 🔥 Ne Yaptık? (V1 Özellikleri)

1.  **Core (Çekirdek) Servisler:** Cihazların güvenli alanını (Safe Area) milisaniyeler içinde hesaplayan bağımsız sistemler oluşturduk.
2.  **Editor Dock Panel:** Birden fazla node seçildiğinde bile hepsini tek tıkla güvenli alana yerleştiren (Batch Apply) ve Godot'nun sol paneline yerleşen bir araç yaptık.
3.  **Inspector Entegrasyonu:** Daha "Native" bir Godot deneyimi için, bir `Control` objesi seçildiğinde sağ panelin (Inspector) en üstüne kestirme bir buton ekledik.
4.  **Undo/Redo Sistemi:** Yapılan düzeltmelerin Godot'nun standart `Ctrl+Z` mekanizması ile tam uyumlu ve geri alınabilir olmasını sağladık.
5.  **Debug Kırmızı Örtü:** Geliştirme aşamasındayken ekrandaki tehlikeli "ölü bölgeleri" kırmızıyla gösteren bir görselleştirici yaptık.

---

## 🎮 Nasıl Kullanılır? (Kullanım Senaryosu)

SafeNest UI, "her şeyi bir anda yapan kompleks bir UI framework'ü" **değildir**. Spesifik bir sorunu ("Çentik Sorunu") çözmek için tasarlanmış sivri bir bıçaktır.

**Doğru Kullanım Şekli:**
1.  Oyun sahnenin UI (CanvasLayer vs.) katmanına bir adet ana `Control` (örneğin adı: `SafeRoot`) ekleyin.
2.  Bu `SafeRoot` node'unu seçili hale getirin.
3.  Sağ taraftaki Inspector panelinin en üstünde beliren **"🎯 Apply Mobile Safe Layout"** butonuna (veya Dock Panel'deki butona) tıklayın.
4.  Artık bu node, sistem çubukları veya kamera çentikleri dışındaki **güvenli alanı** kaplayacak şekilde kilitlendi.
5.  Bütün butonlarınızı, joystick'lerinizi ve metinlerinizi bu `SafeRoot`'un içine (Child olarak) "Anchor/Container" kurallarına göre dizin.

Böylece içindeki hiçbir eleman taşma veya gizli kalma problemi yaşamayacak.

---

## 🧪 Test Özellikleri

*   **Çoklu Seçim (Batch):** Sahnede `Shift` tuşuna basılı tutarak 5-10 tane Control node'u seçip işlemi aynı anda uygulayabilirsiniz.
*   **Görsel Hata Ayıklama:** `DemoScene` içindeki gibi, `safe_area_overlay.gd` sınıfını projenin en üstüne atarak nerenin "yasaklı alan" olduğunu kırmızı ile görebilirsiniz. Rengi Inspector üzerinden ayarlanabilir.
