Инициализируется пакет `refind` при помощи собственного скрипта `refind-install`.

```bash
pacman -S refind

refind-install
```

Устанавливает `refind` все свои файлы в EFI раздел жёсткого диска, путь `/boot/efi/EFI/refind`. В данном каталоге находится всё необходимое. Для настройки собственного меню (установки темы, смены значков) есть файл `refind.conf` в котором можно указать нужные опции для `refind`.

Элементы меню настраиваются в блоке `menuentry` и имееют следующую структуру:
```bash
# Время после которого refind сам запустит систему в случае бездействия пользователя
timeout 20
use_nvram false
# Отключение автоопределения refind в пользу ручных menuentry
scanfor manual,external,optical

menuentry "Gnome" {
	# Путь до иконки
    icon     /EFI/refind/themes/refind-theme-regular/icons/256-96/os_gnome.png
	# Указывается unique GUID (Linux filesystem) раздела жёсткого диска
    volume   F95B5393-2F1A-41AE-A320-4C0FCD3A7B2A
    # Параметры loader и initrd важно указывать путь без / в начале
    loader   boot/vmlinuz-linux
    initrd   boot/initramfs-linux.img
    # Параметры загрузки
    options  "root=/dev/nvme0n1p3 ro"
    
    # Взято из примера конфига
    submenuentry "Boot using fallback initramfs" {
        initrd /boot/initramfs-linux-fallback.img
    }
    submenuentry "Boot to terminal" {
        add_options "systemd.unit=multi-user.target"
    }

	# Отключения данного элемента, если установлен, то в меню не будет отображаться
	disable
}

# Подключение темы
include themes/refind-theme-regular/theme.conf
```

Для просмотра unique GUID выполняется данная команда:
```bash
# 2 - это номер раздела диска /dev/sda. В любом случае указывается номер root (Linux filesystem) раздела
sudo sgdisk -i 2 /dev/sda
```

Тем самым можно установиться любое^[сколько хватит место на диске] количество операционных систем. Для каждой операционной системы создаётся свой собственный `menuentry` в файле `refind.conf`.