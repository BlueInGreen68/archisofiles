Данное решние проверено только на моём ноутбуке - _MainBenBen XiaoMai 6Pro-E5100_.

Устранение проблем связанных с отключение Wi-Fi модуля и его вылета. 

Для устранения нужно создать два файла в папке `/etc/modprobe.d/`:  `iwlwifi.conf`, `iwlmvm.conf` со следующим содержимым.

```bash
# /etc/modprobe.d/iwlwifi.conf
options iwlwifi 11n_disable=1
options iwlwifi swcrypto=0
options iwlwifi bt_coex_active=0
options iwlwifi power_save=0
options iwlwifi uapsd_disable=1
```

```bash
# /etc/modprobe.d/iwlmvm.conf
options iwlmvm power_scheme=1
```