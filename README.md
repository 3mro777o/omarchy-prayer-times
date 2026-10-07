# Omarchy Prayer Times

ويدجت لمواقيت الصلاة في شريط [Omarchy](https://omarchy.org/)، تأخذ المواقيت من [Mawaqit](https://mawaqit.net)، وخدمة بالخلفية للتنبيه والأذان.

A prayer-times widget for the Omarchy shell bar, with times from a Mawaqit mosque page, and a background service for reminders and the adhan.

## المميزات
- الصلاة القادمة في الشريط، وتتحول إلى عدّ تنازلي قبل الأذان بساعة.
- نافذة فيها عدّ تنازلي، والتاريخ الميلادي والهجري، والصلوات الست مع الإقامة، ووقت الجمعة.
- إشعار وصوت قبل الأذان بـ 20 دقيقة.
- أذان كامل عند دخول الوقت، وأذان خاص للفجر.
- الأذان يشتغل على سماعة تختارها، وإذا كانت مفصولة يشتغل على السماعة الافتراضية.
- المواقيت محفوظة على الجهاز، فيكمل بدون إنترنت.

## التثبيت
```bash
git clone https://github.com/3mro777o/omarchy-prayer-times.git
cd omarchy-prayer-times
./install.sh
```

## الإعدادات
في أول ملف `bin/prayer-times`:

| المتغير | المعنى |
|---|---|
| `MOSQUE_URL` | رابط صفحة المسجد على mawaqit.net |
| `PREFERRED_SINK` | جزء من اسم السماعة في `pactl list sinks short` |
| `REMIND_MINUTES` | كم دقيقة قبل الأذان يجي التنبيه |

بعد أي تعديل: `systemctl --user restart prayer-times`

## الاستخدام
| | |
|---|---|
| كبسة يسار على الويدجت | فتح نافذة المواقيت |
| كبسة يمين | إيقاف الأذان |
| كبسة وسط | تحديث المواقيت |

```bash
prayer-times next    # الصلاة القادمة
prayer-times test    # تجربة الأذان
prayer-times stop    # إيقاف الأذان
prayer-times fetch   # تحديث المواقيت
```

## المتطلبات
Omarchy (Quickshell shell)، و Python 3، و `mpv`، و `pactl`، و `notify-send`.

ملفات الصوت لا تُرفع مع المشروع. `install.sh` يحمّلها من mawaqit.net.
