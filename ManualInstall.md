1. Команда `iwctl`.
```bash
# Старт оболочки команды
iwctl

# Поиска Wi-Fi модуля
device list

# Включение поиска сетей. wlan0 - имя Wi-Fi модуля
station wlan0 scan
# Список найденных сетей
station wlan0 get-networks

# Подклюения к сети TP-Link_356E
station wlan0 connect TP-Link_356E
```
2. Команда `timedatectl`.
```bash
# Включение  синхронизации сетевого времени
timedatectl set-ntp true
```
3. Создание разделов. Команда `fdisk` или `cfdisk`.

	Проще использовать команду `cfdisk`.
	```bash
	# Просмотр доступных дисков
	lsblk -l

	# Запуск программы cfdisk. /dev/nvme0n1 - диск
	cfdisk /dev/nvme0n1
	```

	Важно! Нужно указывать диск целиком, а не отдельную его часть.

	Разделы следующие:
	- `550M` под EFI раздел;
	- `2G` под SWAP раздел;
	- всё оставшееся место под `root`.

	Также важно указать правильный тип разделов:
	- EFI - `1`;
	- SWAP - `19`;

	Создание файловых систем и другие операции на этих разделах делается через данные команды:
	```bash
	# Создание файловой системы для EFI раздела
	mkfs.fat -F32 /dev/nvme0n1p1

	# Настройка SWAP раздела
	mkswap /dev/nvme0n1p2

	# Активация SWAP
	swapon /dev/nvme0n1p2

	# Создание файловой системы для root раздела
	mkfs.ext4 /dev/nvme0n1p3
	```

4. Монтирование `root` раздела.
```bash
mount /dev/nvme0n1p3 /mnt
```

5. Установка основных пакетов.
```bash
pacstrap /mnt base linux linux-firmware nano foot keepassxc wget python-pipx git wl-clipboard neovim chezmoi networkmanager sway gum jq sudo rsync base-devel
```

6. Генерация файла `fstab`.
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

7. Переход к корневому каталогу.
```bash
arch-chroot /mnt
```

8. Настройка времени.
```bash
ln -sf /usr/share/zoneinfo/Asia/Yekaterinburg

hwclock --systohc
```

9. Генерация локали. Для этого нужно отредактировать файл `/etc/local.gen` и убрать комментарии у нужных нам языков. Обычно это `en_US.UTF-8` и `ru_RU.UTF-8`.

```bash
nano /etc/locale.gen

locale-gen
```

10. Установка имени компьютера.
```bash
# /etc/hostname
<Имя комьютера>
```

11. Редактирование файла `hosts`.
```bash
# /etc/hosts
127.0.0.1    localhost
::1          localhost
127.0.1.1    <Имя компьютера>.localdomain    <Имя компьютера>
```

12. Установка `root` пароля.
```bash
passwd
```

13. Добавление пользователя и установка пароля.
```bash
useradd -m <Имя пользователя>

passwd <Имя пользователя>
```

14. Добавления пользователя в нужные группы.
```bash
usermod -aG wheel,audio,video,storage <Имя пользователя>
```

15. Редактирование конфигурационного файла `sudoers`.

	Важно! Расскоментируется строка с комментарием <code class="green">Uncomment to allow members of group wheel to execute any command</code>.
	```bash
	EDITOR=nano visudo
	```


16. Установка пакета `NetworkManager`.
```bash
systemctl enable NetworkManager
```

17. Настройка и установка пакета `refind`.
```bash
pacman -S refind gdisk

refind-install
```

18. Выход из Chroot, отмонтирование `root` диска и перезагрузка.
```bash
exit

umount /mnt -l

reboot
```

Если после установки не получается зайти в новую систему, возможно нужно отредактировать файл `refind.conf` или `refind-linux.conf` в EFI разделе. Это можно сделать через установочную флешку.

Основные [[Refind|моменты]] по настройке `refind`.
