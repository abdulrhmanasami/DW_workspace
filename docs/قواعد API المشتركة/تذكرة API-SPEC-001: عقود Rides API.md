# تذكرة API-SPEC-001: عقود Rides API

هذا المستند يحدد عقود API الخاصة بمسار الرحلات (Rides) في تطبيق Delivery Ways، بما في ذلك تعريف الكيانات الأساسية ونقاط النهاية (Endpoints) المطلوبة.

---

## 1. الكيانات الأساسية (Core Schemas)

### 1.1. Location (الموقع)

يمثل نقطة جغرافية محددة (التقاط، إنزال، أو موقع حالي).

#### Fields

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `lat` | number | yes | خط العرض (Latitude). |
| `lng` | number | yes | خط الطول (Longitude). |
| `address` | string | yes | العنوان النصي الكامل للموقع. |
| `place_id` | string | no | معرف المكان من مزود الخرائط (مثل Google Place ID). |

#### Example

```json
{
  "lat": 24.7136,
  "lng": 46.6753,
  "address": "Riyadh Front, Riyadh, Saudi Arabia"
}
```

### 1.2. PriceEstimate (تقدير السعر)

يمثل تقدير السعر للرحلة قبل تأكيدها.

#### Fields

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `currency` | string | yes | رمز العملة (مثال: "SAR"). |
| `min` | number | yes | الحد الأدنى للسعر المقدر. |
| `max` | number | yes | الحد الأقصى للسعر المقدر. |
| `service_type` | string | yes | نوع الخدمة التي ينطبق عليها التقدير (مثال: "ride_economy"). |

#### Example

```json
{
  "currency": "SAR",
  "min": 18.5,
  "max": 24.0,
  "service_type": "ride_economy"
}
```

### 1.3. Vehicle (المركبة)

يمثل تفاصيل المركبة المخصصة للرحلة.

#### Fields

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `plate_number` | string | yes | رقم لوحة المركبة. |
| `make` | string | yes | الشركة المصنعة (مثال: "Toyota"). |
| `model` | string | yes | طراز المركبة (مثال: "Camry"). |
| `color` | string | yes | لون المركبة. |

#### Example

```json
{
  "plate_number": "أ ب ج 1234",
  "make": "Toyota",
  "model": "Camry",
  "color": "White"
}
```

### 1.4. Driver (السائق)

يمثل تفاصيل السائق المخصص للرحلة.

#### Fields

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | string | yes | معرف السائق (مثال: "driver_789"). |
| `name` | string | yes | اسم السائق. |
| `rating` | number | yes | تقييم السائق (مثال: 4.8). |
| `phone_number` | string | yes | رقم هاتف السائق. |
| `vehicle` | Vehicle | yes | تفاصيل المركبة (راجع 1.3). |
| `current_location` | Location | no | الموقع الحالي للسائق (يُستخدم لتتبع وصوله). |

#### Example

```json
{
  "id": "driver_789",
  "name": "Fahad Al-Otaibi",
  "rating": 4.8,
  "phone_number": "+966501234567",
  "vehicle": {
    "plate_number": "أ ب ج 1234",
    "make": "Toyota",
    "model": "Camry",
    "color": "White"
  },
  "current_location": {
    "lat": 24.7140,
    "lng": 46.6750,
    "address": "Near Riyadh Front"
  }
}
```

### 1.5. TripEvent (حدث الرحلة)

يمثل نقطة زمنية في تاريخ حالة الرحلة (Timeline).

#### Fields

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | string | yes | معرف الحدث (مثال: "event_1"). |
| `status` | string | yes | حالة الرحلة الجديدة (مثال: "driver_assigned"). |
| `timestamp` | datetime | yes | وقت حدوث التغيير (ISO8601 UTC). |
| `details` | object | no | تفاصيل إضافية متعلقة بالحدث (مثال: سبب الإلغاء). |

#### Example

```json
{
  "id": "event_1",
  "status": "driver_assigned",
  "timestamp": "2025-01-01T10:02:30Z",
  "details": {
    "driver_id": "driver_789"
  }
}
```

### 1.6. Trip (الرحلة)

الكيان الأساسي الذي يمثل الرحلة.

#### Fields

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | string | yes | معرف الرحلة الفريد (مثال: "trip_123"). |
| `rider_id` | string | yes | معرف المستخدم طالب الرحلة. |
| `driver` | Driver | no | تفاصيل السائق المخصص (موجود إذا كانت الحالة `driver_assigned` أو ما بعدها). |
| `status` | string | yes | حالة الرحلة الحالية. |
| `service_type` | string | yes | نوع الخدمة المطلوبة (مثال: "ride_economy", "ride_premium"). |
| `pickup` | Location | yes | نقطة الالتقاط. |
| `dropoff` | Location | yes | نقطة الإنزال. |
| `price_estimate` | PriceEstimate | no | تقدير السعر قبل التأكيد. |
| `final_price` | object | no | السعر النهائي بعد اكتمال الرحلة. |
| `eta_minutes` | integer | no | الوقت المقدر لوصول السائق (في حالة `searching_driver` أو `driver_assigned`). |
| `created_at` | datetime | yes | وقت إنشاء الطلب. |
| `updated_at` | datetime | yes | وقت آخر تحديث للحالة. |

#### Trip Statuses (حالات الرحلة)

يجب أن تغطي الحالات التالية سيناريو مستوى Uber:

*   `requested`: تم طلب الرحلة.
*   `searching_driver`: جاري البحث عن سائق.
*   `driver_assigned`: تم تخصيص سائق.
*   `en_route_to_pickup`: السائق في طريقه لنقطة الالتقاط.
*   `arrived`: السائق وصل لنقطة الالتقاط.
*   `in_progress`: الرحلة بدأت (الراكب في المركبة).
*   `completed`: الرحلة اكتملت بنجاح.
*   `canceled`: تم إلغاء الرحلة.
*   `failed`: فشلت الرحلة (مثال: فشل في العثور على سائق).

#### Example

```json
{
  "id": "trip_123",
  "rider_id": "user_456",
  "driver": {
    "id": "driver_789",
    "name": "Fahad Al-Otaibi",
    "rating": 4.8,
    "phone_number": "+966501234567",
    "vehicle": {
      "plate_number": "أ ب ج 1234",
      "make": "Toyota",
      "model": "Camry",
      "color": "White"
    },
    "current_location": {
      "lat": 24.7140,
      "lng": 46.6750,
      "address": "Near Riyadh Front"
    }
  },
  "status": "driver_assigned",
  "service_type": "ride_economy",
  "pickup": {
    "lat": 24.7136,
    "lng": 46.6753,
    "address": "Riyadh Front, Riyadh, Saudi Arabia"
  },
  "dropoff": {
    "lat": 24.7743,
    "lng": 46.7386,
    "address": "Al Olaya, Riyadh, Saudi Arabia"
  },
  "price_estimate": {
    "currency": "SAR",
    "min": 18.5,
    "max": 24.0,
    "service_type": "ride_economy"
  },
  "eta_minutes": 7,
  "created_at": "2025-01-01T10:00:00Z",
  "updated_at": "2025-01-01T10:02:30Z"
}
```

---

## 2. نقاط النهاية (Endpoints)

### 2.1. `POST /v1/rides/quote` - الحصول على تقدير سعر الرحلة

**الوصف:** يوفر تقديرات الأسعار والوقت المتوقع للوصول (ETA) لأنواع الخدمات المتاحة بين نقطتي التقاط وإنزال.

**Authentication:** Bearer Token

#### Request Body

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `pickup` | Location | yes | نقطة الالتقاط. |
| `dropoff` | Location | yes | نقطة الإنزال. |

**Example Request:**

```json
{
  "pickup": {
    "lat": 24.7136,
    "lng": 46.6753,
    "address": "Riyadh Front"
  },
  "dropoff": {
    "lat": 24.7743,
    "lng": 46.7386,
    "address": "Al Olaya"
  }
}
```

#### Response 200

**الوصف:** قائمة بتقديرات الأسعار لكل نوع خدمة متاح.

**Example Response:**

```json
{
  "quotes": [
    {
      "service_type": "ride_economy",
      "price_estimate": {
        "currency": "SAR",
        "min": 18.5,
        "max": 24.0,
        "service_type": "ride_economy"
      },
      "eta_minutes": 7
    },
    {
      "service_type": "ride_premium",
      "price_estimate": {
        "currency": "SAR",
        "min": 35.0,
        "max": 45.0,
        "service_type": "ride_premium"
      },
      "eta_minutes": 5
    }
  ]
}
```

#### Errors

*   `400 Bad Request`: `invalid_request` (إذا كانت إحداثيات الموقع غير صالحة).
*   `401 Unauthorized`: `unauthorized` (رمز وصول غير صالح).
*   `404 Not Found`: `not_found` (إذا لم يتم العثور على خدمات متاحة للمسار).

### 2.2. `POST /v1/rides` - طلب رحلة جديدة

**الوصف:** إنشاء طلب رحلة جديد وبدء عملية البحث عن سائق.

**Authentication:** Bearer Token

#### Request Body

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `service_type` | string | yes | نوع الخدمة المطلوب (مثال: "ride_economy"). |
| `pickup` | Location | yes | نقطة الالتقاط. |
| `dropoff` | Location | yes | نقطة الإنزال. |
| `payment_method_id` | string | yes | معرف طريقة الدفع المختارة. |

**Example Request:**

```json
{
  "service_type": "ride_economy",
  "pickup": {
    "lat": 24.7136,
    "lng": 46.6753,
    "address": "Riyadh Front"
  },
  "dropoff": {
    "lat": 24.7743,
    "lng": 46.7386,
    "address": "Al Olaya"
  },
  "payment_method_id": "card_1234"
}
```

#### Response 200

**الوصف:** إرجاع كيان الرحلة المنشأة حديثًا، وستكون حالتها الأولية `requested` أو `searching_driver`.

**Example Response:**

```json
{
  "trip": {
    "id": "trip_456",
    "rider_id": "user_456",
    "status": "searching_driver",
    "service_type": "ride_economy",
    "pickup": {
      "lat": 24.7136,
      "lng": 46.6753,
      "address": "Riyadh Front"
    },
    "dropoff": {
      "lat": 24.7743,
      "lng": 46.7386,
      "address": "Al Olaya"
    },
    "created_at": "2025-01-01T11:00:00Z",
    "updated_at": "2025-01-01T11:00:00Z"
  }
}
```

#### Errors

*   `400 Bad Request`: `invalid_request` (حقول مفقودة أو غير صالحة).
*   `409 Conflict`: `conflict` (إذا كان المستخدم لديه رحلة نشطة بالفعل).

### 2.3. `GET /v1/rides/{id}` - استرداد تفاصيل رحلة

**الوصف:** استرداد تفاصيل رحلة محددة باستخدام معرفها.

**Authentication:** Bearer Token

#### Path Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `id` | string | معرف الرحلة (مثال: `trip_123`). |

#### Response 200

**الوصف:** إرجاع كيان الرحلة (Trip) كاملاً.

**Example Response:** (راجع مثال كيان Trip في 1.6)

#### Errors

*   `401 Unauthorized`: `unauthorized` (رمز وصول غير صالح).
*   `403 Forbidden`: `forbidden` (الرحلة لا تخص المستخدم الحالي).
*   `404 Not Found`: `not_found` (الرحلة غير موجودة).

### 2.4. `GET /v1/rides/{id}/events` - استرداد سجل أحداث الرحلة

**الوصف:** استرداد سجل الأحداث الزمني (Timeline) لتغيرات حالة الرحلة.

**Authentication:** Bearer Token

#### Path Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `id` | string | معرف الرحلة (مثال: `trip_123`). |

#### Response 200

**الوصف:** قائمة مرتبة زمنيًا بأحداث الرحلة (TripEvent).

**Example Response:**

```json
{
  "events": [
    {
      "id": "event_1",
      "status": "requested",
      "timestamp": "2025-01-01T10:00:00Z"
    },
    {
      "id": "event_2",
      "status": "searching_driver",
      "timestamp": "2025-01-01T10:00:05Z"
    },
    {
      "id": "event_3",
      "status": "driver_assigned",
      "timestamp": "2025-01-01T10:02:30Z",
      "details": {
        "driver_id": "driver_789"
      }
    }
  ]
}
```

#### Errors

*   `401 Unauthorized`: `unauthorized`.
*   `403 Forbidden`: `forbidden`.
*   `404 Not Found`: `not_found`.

### 2.5. `POST /v1/rides/{id}/cancel` - إلغاء رحلة

**الوصف:** إلغاء رحلة نشطة.

**Authentication:** Bearer Token

#### Path Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `id` | string | معرف الرحلة المراد إلغاؤها. |

#### Request Body

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `reason` | string | no | سبب الإلغاء (يُستخدم لأغراض التحليل). |

**Example Request:**

```json
{
  "reason": "Driver is too far away"
}
```

#### Response 200

**الوصف:** إرجاع كيان الرحلة المحدث، وستكون حالتها `canceled`.

**Example Response:**

```json
{
  "trip": {
    "id": "trip_456",
    "rider_id": "user_456",
    "status": "canceled",
    "created_at": "2025-01-01T11:00:00Z",
    "updated_at": "2025-01-01T11:05:00Z"
    // ... بقية حقول الرحلة
  }
}
```

#### Errors

*   `401 Unauthorized`: `unauthorized`.
*   `403 Forbidden`: `forbidden`.
*   `404 Not Found`: `not_found`.
*   `409 Conflict`: `conflict` (إذا كانت الرحلة في حالة لا يمكن إلغاؤها، مثل `completed` أو `in_progress`).
