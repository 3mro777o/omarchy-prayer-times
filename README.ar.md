<div dir="rtl">

# مواقيت الصلاة لـ Omarchy

[English](README.md) | **العربية**

ويدجت لمواقيت الصلاة في شريط [Omarchy](https://omarchy.org/). المواقيت تؤخذ من صفحة مسجد على [Mawaqit](https://mawaqit.net)، وخدمة تعمل في الخلفية للتنبيه والأذان.

## المميزات
- الصلاة القادمة في الشريط مع الوقت المتبقي للأذان أو ساعة الأذان (تختار من النافذة).
- الواجهة والإشعارات بالعربية أو الإنجليزية (زر في النافذة، والافتراضي الإنجليزية).
- نافذة فيها عدّ تنازلي، والتاريخ الميلادي والهجري، والمواقيت الستة مع الإقامة، ووقت الجمعة.
- إشعار وصوت تنبيه قبل كل أذان بـ 20 دقيقة.
- الأذان كاملاً عند دخول الوقت، وأذان خاص بالفجر.
- الأذان يعمل على سماعة تختارها، وإذا كانت مفصولة يعمل على السماعة الافتراضية.
- المواقيت محفوظة على الجهاز، فيعمل بدون إنترنت.

## التثبيت
</div>

```bash
git clone https://github.com/3mro777o/omarchy-prayer-times.git
cd omarchy-prayer-times
./install.sh
```

<div dir="rtl">

سكربت التثبيت يقوم بـ:
- نسخ `prayer-times` إلى `~/.local/bin` والويدجت إلى `~/.config/omarchy/plugins/blacknova.prayer-times`.
- تحميل أصوات الأذان والتنبيه من mawaqit.net (غير موجودة في المستودع).
- تثبيت `mpv` إذا لم يكن موجوداً.
- تفعيل خدمة `prayer-times` في systemd للمستخدم، وتفعيل الويدجت في الشريط.

## الإعدادات
في أول ملف `bin/prayer-times` (أو `~/.local/bin/prayer-times` بعد التثبيت):

| المتغير | المعنى |
|---|---|
| `MOSQUE_URL` | رابط صفحة مسجدك على mawaqit.net (الافتراضي مسجد الإيمان في هامبورغ) |
| `PREFERRED_SINK` | جزء من اسم السماعة كما يظهر في `pactl list sinks short` |
| `REMIND_MINUTES` | كم دقيقة قبل الأذان يأتي التنبيه |

بعد أي تعديل:
</div>

```bash
prayer-times fetch
systemctl --user restart prayer-times
```

<div dir="rtl">

## الاستخدام
| الحركة | النتيجة |
|---|---|
| ضغطة يسار على الويدجت | فتح نافذة المواقيت |
| ضغطة يمين | إيقاف الأذان |
| ضغطة وسط | تحديث المواقيت |

</div>

```bash
prayer-times next        # الصلاة القادمة
prayer-times test [fajr] # تجربة الأذان الآن (أذان الفجر مع fajr)
prayer-times stop        # إيقاف الأذان
prayer-times fetch       # تحديث المواقيت من mawaqit.net
```

<div dir="rtl">

## المتطلبات
Omarchy (واجهة Quickshell)، و Python 3، و `mpv`، و `pactl`، و `notify-send`، و `curl`.

</div>
