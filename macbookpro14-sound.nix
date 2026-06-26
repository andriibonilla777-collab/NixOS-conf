# macbookpro14-sound.nix
#
# Включает рабочий внутренний звук (динамики + микрофон) на MacBookPro14,1
# (13", 2017, два порта Thunderbolt 3) под NixOS на ядре >=6.17.
#
# Проблема: с ядра 6.17 в mainline Linux появился родной драйвер
# snd-hda-codec-cs8409 (видно по dmesg: "autoconfig for CS8409"), но в нём
# нет Apple-специфичной инициализации усилителей (MAX98706/SSM3515) —
# поэтому карта определяется, PipeWire её видит, но физически звука нет.
#
# Решение: патчим sound/hda/codecs/cirrus/{cs8409.c,cs8409.h} тем же
# патчем, что используют davidjo/snd_hda_macbookpro (egorenar fork) —
# но не через DKMS (на NixOS его нет), а как boot.kernelPatches, то есть
# патч встраивается прямо в сборку ядра NixOS. Патч сгенерирован и
# ПРОВЕРЕН на применение (patch -p1) к реальному дереву исходников
# Linux 6.18 (sound/hda/codecs/cirrus), взятому из того же fetchurl-тарбола,
# который NixOS использует для сборки вашего текущего ядра.
#
# Установка:
#   1) Положите файлы macbookpro14-cs8409-amp.patch и macbookpro14-sound.nix
#      в /etc/nixos/ (рядом с configuration.nix)
#   2) В configuration.nix добавьте в imports:
#        imports = [ ./macbookpro14-sound.nix ];
#   3) sudo nixos-rebuild switch
#      (это пересоберёт ядро целиком — на i5-7360U может занять
#      от 20 до 60+ минут, в зависимости от загрузки и параллелизма)
#   4) Перезагрузитесь и проверьте:
#        dmesg | grep -i cs8409
#        wpctl status
#      Попробуйте звук на "Аналоговый объёмный 2.1" / "Аналоговый стерео
#      Дуплекс" профиле в pavucontrol — динамики и микрофон должны заработать.

{ ... }:

{
  boot.kernelPatches = [
    {
      name = "macbookpro14-1-cs8409-apple-amp-fixups";
      patch = ./macbookpro14-cs8409-amp.patch;
    }
  ];

  # Эта опция у вас уже стоит в кернел-параметрах (видно в dmesg) —
  # оставляем явно в конфиге, чтобы не потерять при следующей правке:
  boot.kernelParams = [ "snd-hda-intel.model=intel-mac-auto" ];
}
