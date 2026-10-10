.pragma library

// calendar row: [fajr, shuruq, dhuhr, asr, maghrib, isha]
var PRAYERS = [
  { key: "fajr",    idx: 0, iqama: 0, adhan: true },
  { key: "shuruq",  idx: 1, iqama: -1, adhan: false },
  { key: "dhuhr",   idx: 2, iqama: 1, adhan: true },
  { key: "asr",     idx: 3, iqama: 2, adhan: true },
  { key: "maghrib", idx: 4, iqama: 3, adhan: true },
  { key: "isha",    idx: 5, iqama: 4, adhan: true }
]

// UI strings per language; settings.lang picks one, English by default.
var STR = {
  en: {
    fajr: "Fajr", shuruq: "Sunrise", dhuhr: "Dhuhr", asr: "Asr", maghrib: "Maghrib", isha: "Isha", jumua: "Jumu'ah",
    adhanIn: "%1 adhan in", sunriseIn: "Sunrise in", loading: "Loading prayer times…", tomorrow: "Tomorrow",
    prayer: "Prayer", adhan: "Adhan", iqama: "Iqama", h: "h", m: "m",
    stop: "Stop adhan", test: "Test adhan", refresh: "Refresh",
    showCountdown: "Bar: time left", showTime: "Bar: adhan time", language: "العربية",
    months: ["Muharram", "Safar", "Rabi' al-Awwal", "Rabi' al-Thani", "Jumada al-Ula", "Jumada al-Akhirah",
             "Rajab", "Sha'ban", "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"], ah: "AH"
  },
  ar: {
    fajr: "الفجر", shuruq: "الشروق", dhuhr: "الظهر", asr: "العصر", maghrib: "المغرب", isha: "العشاء", jumua: "الجمعة",
    adhanIn: "أذان %1 بعد", sunriseIn: "الشروق بعد", loading: "جارٍ تحميل المواقيت…", tomorrow: "غداً",
    prayer: "الصلاة", adhan: "الأذان", iqama: "الإقامة", h: "س", m: "د",
    stop: "إيقاف الأذان", test: "تجربة الأذان", refresh: "تحديث",
    showCountdown: "الشريط: المتبقي", showTime: "الشريط: ساعة الأذان", language: "English",
    months: ["محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة",
             "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"], ah: "هـ"
  }
}

function tr(lang, k) { return (STR[lang] || STR.en)[k] }

function parse(text) {
  try { return JSON.parse(text) } catch (e) { return null }
}

function at(day, hhmm) {
  var p = String(hhmm || "").split(":")
  if (p.length < 2) return null
  return new Date(day.getFullYear(), day.getMonth(), day.getDate(), parseInt(p[0], 10), parseInt(p[1], 10), 0)
}

function pad(n) { return (n < 10 ? "0" : "") + n }
function hm(d) { return d ? pad(d.getHours()) + ":" + pad(d.getMinutes()) : "--:--" }

function dayTimes(data, day, lang) {
  if (!data || !data.calendar) return []
  var month = data.calendar[day.getMonth()]
  var row = month ? month[String(day.getDate())] : null
  if (!row) return []
  var iq = data.iqamaCalendar && data.iqamaCalendar[day.getMonth()]
  var iqRow = iq ? iq[String(day.getDate())] : null
  var friday = day.getDay() === 5
  var out = []
  for (var i = 0; i < PRAYERS.length; i++) {
    var p = PRAYERS[i]
    var t = at(day, row[p.idx])
    var iqama = null
    if (p.iqama >= 0 && iqRow && iqRow[p.iqama]) {
      var v = String(iqRow[p.iqama])
      if (v.charAt(0) === "+") iqama = new Date(t.getTime() + parseInt(v.slice(1), 10) * 60000)
      else iqama = at(day, v)
    }
    var name = tr(lang, p.key)
    if (friday && p.key === "dhuhr" && data.jumua) {
      name = tr(lang, "jumua")
      iqama = at(day, data.jumua)
    }
    out.push({ key: p.key, name: name, time: t, iqama: iqama, adhan: p.adhan })
  }
  return out
}

// Next prayer time (sunrise included) after `now`, rolling into tomorrow after isha.
function nextPrayer(data, now, lang) {
  for (var d = 0; d < 2; d++) {
    var day = new Date(now.getFullYear(), now.getMonth(), now.getDate() + d)
    var list = dayTimes(data, day, lang)
    for (var i = 0; i < list.length; i++)
      if (list[i].time > now) return list[i]
  }
  return null
}

function previousPrayer(data, now, lang) {
  for (var d = 0; d < 2; d++) {
    var day = new Date(now.getFullYear(), now.getMonth(), now.getDate() - d)
    var list = dayTimes(data, day, lang)
    for (var i = list.length - 1; i >= 0; i--)
      if (list[i].time <= now) return list[i]
  }
  return null
}

function countdown(ms, withSeconds, lang) {
  if (ms < 0) ms = 0
  var s = Math.floor(ms / 1000)
  var h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60), sec = s % 60
  return withSeconds ? pad(h) + ":" + pad(m) + ":" + pad(sec) : (h > 0 ? h + tr(lang, "h") + " " + m + tr(lang, "m") : m + tr(lang, "m"))
}

// Tabular (Kuwaiti) Islamic calendar; mawaqit's hijriAdjustment shifts it.
function hijri(date, adjust, lang) {
  var d = new Date(date.getFullYear(), date.getMonth(), date.getDate() + (adjust || 0))
  var y = d.getFullYear(), m = d.getMonth() + 1, day = d.getDate()
  if (m < 3) { y -= 1; m += 12 }
  var a = Math.floor(y / 100), b = 2 - a + Math.floor(a / 4)
  var jd = Math.floor(365.25 * (y + 4716)) + Math.floor(30.6001 * (m + 1)) + day + b - 1524
  var l = jd - 1948440 + 10632
  var n = Math.floor((l - 1) / 10631)
  l = l - 10631 * n + 354
  var j = Math.floor((10985 - l) / 5316) * Math.floor((50 * l) / 17719) + Math.floor(l / 5670) * Math.floor((43 * l) / 15238)
  l = l - Math.floor((30 - j) / 15) * Math.floor((17719 * j) / 50) - Math.floor(j / 16) * Math.floor((15238 * j) / 43) + 29
  var hm_ = Math.floor((24 * l) / 709)
  var hd = l - Math.floor((709 * hm_) / 24)
  var hy = 30 * n + j - 30
  return hd + " " + tr(lang, "months")[hm_ - 1] + " " + hy + " " + tr(lang, "ah")
}
