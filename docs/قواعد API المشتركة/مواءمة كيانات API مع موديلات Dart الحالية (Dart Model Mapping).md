# مواءمة كيانات API مع موديلات Dart الحالية (Dart Model Mapping)

هذا المستند يوضح المواءمة (Mapping) بين كيانات (Schemas) API المحددة في ملفات OpenAPI (`openapi_rides.yaml`, `openapi_orders.yaml`) وموديلات Dart الحالية الموجودة في حزم الشيمز (Shims) داخل المشروع.

**ملاحظة هامة:** هذا التحليل هو **لغرض التوثيق والمواءمة فقط**، ولا يتضمن أي اقتراح لتعديل كود Dart.

---

## 1. كيانات Rides API

| كيان OpenAPI | حزمة Dart | ملف Dart | اسم Class/Model في Dart | ملاحظات المواءمة |
| :--- | :--- | :--- | :--- | :--- |
| **Location** | `mobility_shims` | `lib/location/models.dart` | `LocationPoint` | يحتوي على `latitude` و `longitude`. لا يحتوي على حقل `address` أو `place_id` مباشرة، مما يتطلب معالجة إضافية في طبقة الـ Uplink. |
| **PriceEstimate** | `payments` | `lib/models.dart` | `Amount` | لا يوجد كيان مطابق تمامًا. `Amount` يمثل قيمة واحدة (`value`, `currency`)، بينما `PriceEstimate` يمثل نطاق (`min`, `max`). يتطلب إنشاء `PriceEstimate` جديد في Dart أو استخدام كيان موجود في `mobility_shims` لم يتم العثور عليه. |
| **Vehicle** | (غير موجود) | (غير موجود) | (غير موجود) | لم يتم العثور على كيان `Vehicle` أو `Driver` صريح في حزم الشيمز التي تم تحليلها. من المحتمل أن تكون هذه الموديلات موجودة في حزمة `mobility_uplink_impl` أو يتم تمثيلها كـ `Map<String, dynamic>` حاليًا. |
| **Driver** | (غير موجود) | (غير موجود) | (غير موجود) | لم يتم العثور على كيان `Driver` صريح. |
| **TripEvent** | `mobility_shims` | `lib/src/types.dart` | `TripEvent` | يوجد تطابق في الاسم، لكن `TripEvent` في Dart يركز على أحداث التسجيل (started, stopped, pointAdded)، بينما في OpenAPI يركز على أحداث دورة حياة الرحلة (driver_assigned, arrived). يتطلب مواءمة دقيقة للحالات. |
| **Trip** | `mobility_shims` | `lib/src/trip_recorder.dart` | `TripSummary` | `TripSummary` في Dart يمثل ملخصًا للرحلة المسجلة (`distanceKm`, `duration`)، وليس كيان دورة حياة الرحلة الكامل (Trip). لا يوجد كيان `Trip` صريح يمثل حالة الرحلة (Status, Driver, Price) في الشيمز الحالية. |

---

## 2. كيانات Orders API

| كيان OpenAPI | حزمة Dart | ملف Dart | اسم Class/Model في Dart | ملاحظات المواءمة |
| :--- | :--- | :--- | :--- | :--- |
| **Address** | `mobility_shims` | `lib/location/models.dart` | `LocationPoint` | كما في كيان Rides، `LocationPoint` هو الأقرب، لكنه يفتقر إلى حقول العنوان النصي وتفاصيل الاتصال (`contact_name`, `contact_phone`) المطلوبة لطلبات التوصيل. |
| **Price** | `payments` | `lib/models.dart` | `Amount` | `Amount` يمثل قيمة واحدة. لا يوجد كيان يمثل تفاصيل السعر الكاملة (`total_amount`, `delivery_fee`, `items_total`)، مما يتطلب إنشاء كيان جديد أو استخدام كيان موجود في حزمة `orders` غير المتاحة للتحليل. |
| **OrderItem** | (غير موجود) | (غير موجود) | (غير موجود) | لم يتم العثور على كيان `OrderItem` صريح في الحزم التي تم تحليلها. |
| **ParcelDetails** | (غير موجود) | (غير موجود) | (غير موجود) | لم يتم العثور على كيان `ParcelDetails` صريح. |
| **Order** | (غير موجود) | (غير موجود) | (غير موجود) | لم يتم العثور على كيان `Order` صريح يمثل حالة الطلب ودورة حياته. |

---

## 3. كيانات Payments API

| كيان OpenAPI | حزمة Dart | ملف Dart | اسم Class/Model في Dart | ملاحظات المواءمة |
| :--- | :--- | :--- | :--- | :--- |
| **PaymentMethod** | `payments` | `lib/src/payment_method.dart` | `PaymentMethod` (Abstract) | يتطابق مع الواجهة المجردة. |
| **SavedPaymentMethod** | `payments` | `lib/models.dart` | `SavedPaymentMethod` | تطابق مباشر. |

---

## 4. ملخص وتحليل الفجوات (Gaps Analysis)

التحليل يظهر أن حزم الشيمز الحالية (`mobility_shims`, `payments`) تركز بشكل أساسي على:
1.  **الواجهات المجردة (Abstract Interfaces)** مثل `TripRecorder` و `PaymentMethod`.
2.  **الموديلات الأساسية (Primitive Models)** مثل `LocationPoint` و `Amount`.

**الفجوة الرئيسية:**
*   **غياب موديلات دورة الحياة (Lifecycle Models):** لا يوجد كيانات صريحة في الشيمز تمثل دورة الحياة الكاملة لـ **Trip** أو **Order** (بما في ذلك الحالة، السائق، السعر النهائي، وتفاصيل الطلب/الرحلة).
*   **غياب موديلات الكيانات المعقدة:** موديلات مثل `Driver`، `Vehicle`، `Price` (التفصيلي)، و `Address` (بالتفاصيل المطلوبة) غير موجودة بشكل صريح.

**الاستنتاج:**
يتطلب الربط بين الـ OpenAPI Specs الجديدة وموديلات Dart الحالية إما:
1.  **إنشاء كيانات جديدة** في Dart (وهو ما سيتم في تذكرة لاحقة).
2.  **افتراض** أن الكيانات المفقودة يتم التعامل معها حاليًا كـ `Map<String, dynamic>` أو أنها موجودة في حزم أخرى لم يتم تحليلها (مثل حزمة `orders` أو `mobility_uplink_impl`).

**التوصية:** يجب أن يتم إنشاء كيانات Dart جديدة (Data Classes) تتطابق مع الـ OpenAPI Schemas لضمان أفضل تجربة لـ Codegen وتجنب الاعتماد على `Map<String, dynamic>`. هذا يضمن أن الـ API Specs الجديدة لن "تكسر الشيمز" بل ستضيف إليها طبقة واضحة من موديلات البيانات.
