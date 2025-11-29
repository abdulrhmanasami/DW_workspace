# B-ui — UI Layer Bootstrap

## الهدف

تهيئة Cursor جديد للـUI ليكون طبقة تجميع واجهات التطبيق فوق الـDesign System (B-ux) وFoundation (B-central)، بدون منطق مجالات (Mobility/Commerce/Accounts)، مع فرض استيرادات قانونية فقط، وترتيب الشاشات والمسارات الأساسية، وتحقيق Analyzer=0 لنطاق الـUI.

## النطاق

- توحيد استيرادات الـUI عبر برميل `lib/ui/ui.dart`
- مكونات UI الأساسية (LoadingView, ErrorView, EmptyState)
- تجميع المسارات UI (legal + dsr)
- قواعد حظر الاستيرادات للـUI
- تقارير وفحوص الجودة

## البنية

```
B-ui/
├── README.md
├── tools/
└── reports/
```

## الاعتمادات

- `design_system_shims` — عبر البرميل فقط
- `foundation_shims` — عبر البرميل فقط
- `flutter/widgets.dart` — مباشرة للمكونات الأساسية

## المسارات المدعومة

- `about/legal` — الشاشات القانونية
- `dsr/export` — تصدير البيانات
- `dsr/erase` — مسح البيانات
