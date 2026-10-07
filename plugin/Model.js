.pragma library

// calendar row: [fajr, shuruq, dhuhr, asr, maghrib, isha]
var PRAYERS = [
  { key: "fajr",    name: "الفجر",   idx: 0, iqama: 0, adhan: true },
  { key: "shuruq",  name: "الشروق",  idx: 1, iqama: -1, adhan: false },
  { key: "dhuhr",   name: "الظهر",   idx: 2, iqama: 1, adhan: true },
  { key: "asr",     name: "العصر",   idx: 3, iqama: 2, adhan: true },
  { key: "maghrib", name: "المغرب",  idx: 4, iqama: 3, adhan: true },
  { key: "isha",    name: "العشاء",  idx: 5, iqama: 4, adhan: true }
]

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

function dayTimes(data, day) {
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
    var name = p.name
    if (friday && p.key === "dhuhr" && data.jumua) {
      name = "الجمعة"
      iqama = at(day, data.jumua)
    }
    out.push({ key: p.key, name: name, time: t, iqama: iqama, adhan: p.adhan })
  }
  return out
}

// Next adhan (shuruq excluded) after `now`, rolling into tomorrow after isha.
function nextPrayer(data, now) {
  for (var d = 0; d < 2; d++) {
    var day = new Date(now.getFullYear(), now.getMonth(), now.getDate() + d)
    var list = dayTimes(data, day)
    for (var i = 0; i < list.length; i++)
      if (list[i].adhan && list[i].time > now) return list[i]
  }
  return null
}

function previousPrayer(data, now) {
  for (var d = 0; d < 2; d++) {
    var day = new Date(now.getFullYear(), now.getMonth(), now.getDate() - d)
    var list = dayTimes(data, day)
    for (var i = list.length - 1; i >= 0; i--)
      if (list[i].adhan && list[i].time <= now) return list[i]
  }
  return null
}

function countdown(ms, withSeconds) {
  if (ms < 0) ms = 0
  var s = Math.floor(ms / 1000)
  var h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60), sec = s % 60
  return withSeconds ? pad(h) + ":" + pad(m) + ":" + pad(sec) : (h > 0 ? h + "س " + m + "د" : m + "د")
}

// Tabular (Kuwaiti) Islamic calendar; mawaqit's hijriAdjustment shifts it.
var HIJRI_MONTHS = ["محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة",
                    "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"]

function hijri(date, adjust) {
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
  return hd + " " + HIJRI_MONTHS[hm_ - 1] + " " + hy + " هـ"
}
