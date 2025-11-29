# تذكرة API-SPEC-001: عقود Orders API (Parcels + Food)

هذا المستند يحدد عقود API الخاصة بمسار الطلبات (Orders) في تطبيق Delivery Ways، وهو مصمم لخدمة كل من طلبات الطرود (Parcels) وطلبات الطعام (Food) باستخدام كيان `Order` موحد.

---

## 1. الكيانات الأساسية (Core Schemas)

### 1.1. Address (العنوان)

يمثل موقعًا جغرافيًا كاملاً لعمليات الالتقاط أو الإنزال.

#### Fields

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `lat` | number | yes | خط العرض (Latitude). |
| `lng` | number | yes | خط الطول (Longitude). |
| `address` | string | yes | العنوان النصي الكامل. |
| `description` | string | no | وصف إضافي للموقع (مثال: "بجانب البوابة الرئيسية"). |
| `contact_name` | string | yes | اسم الشخص المسؤول عن الموقع. |
| `contact_phone` | string | yes | رقم هاتف الشخص المسؤول. |

#### Example

```json
{
  "lat": 24.7136,
  "lng": 46.6753,
  "address": "Riyadh Front, Gate 3",
  "description": "Meet at the main entrance",
  "contact_name": "Ahmed Al-Ali",
  "contact_phone": "+966501234567"
}
```

### 1.2. Price (السعر)

يمثل تفاصيل السعر الإجمالي للطلب.

#### Fields

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `currency` | string | yes | رمز العملة (مثال: "SAR"). |
| `total_amount` | number | yes | المبلغ الإجمالي المدفوع. |
| `delivery_fee` | number | yes | رسوم التوصيل. |
| `items_total` | number | yes | إجمالي سعر العناصر (بدون رسوم التوصيل). |
| `tax_amount` | number | no | مبلغ الضريبة المطبق. |

#### Example

```json
{
  "currency": "SAR",
  "total_amount": 45.0,
  "delivery_fee": 15.0,
  "items_total": 30.0,
  "tax_amount": 5.0
}
```

### 1.3. OrderItem (عنصر الطلب)

يمثل عنصرًا واحدًا داخل الطلب (سواء كان طردًا أو وجبة طعام).

#### Fields

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | string | yes | معرف العنصر (مثال: "item_1"). |
| `name` | string | yes | اسم العنصر (مثال: "Laptop Charger" أو "Chicken Burger"). |
| `quantity` | integer | yes | الكمية المطلوبة. |
| `unit_price` | number | yes | سعر الوحدة الواحدة. |
| `notes` | string | no | ملاحظات خاصة بالعنصر (مثال: "بدون بصل"). |

#### Example

```json
{
  "id": "item_1",
  "name": "Chicken Burger",
  "quantity": 1,
  "unit_price": 30.0,
  "notes": "No onions, extra sauce"
}
```

### 1.4. ParcelDetails (تفاصيل الطرد)

تفاصيل إضافية خاصة بطلبات الطرود (`type: "parcel"`).

#### Fields

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `weight_kg` | number | yes | الوزن التقريبي للطرد بالكيلوغرام. |
| `dimensions_cm` | string | yes | الأبعاد التقريبية (مثال: "20x30x10"). |
| `value_sar` | number | no | القيمة المقدرة لمحتويات الطرد. |
| `category` | string | yes | فئة الطرد (مثال: "Documents", "Electronics"). |

#### Example

```json
{
  "weight_kg": 1.5,
  "dimensions_cm": "20x30x10",
  "value_sar": 500.0,
  "category": "Electronics"
}
```

### 1.5. Order (الطلب)

الكيان الأساسي الذي يمثل طلب توصيل (طرد أو طعام).

#### Fields

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | string | yes | معرف الطلب الفريد (مثال: "order_123"). |
| `type` | string | yes | نوع الطلب: `"parcel"` أو `"food"`. |
| `customer_id` | string | yes | معرف المستخدم الذي قام بالطلب. |
| `driver_id` | string | no | معرف السائق المخصص للطلب. |
| `status` | string | yes | حالة الطلب الحالية. |
| `pickup_address` | Address | yes | عنوان الالتقاط. |
| `dropoff_address` | Address | yes | عنوان الإنزال. |
| `items` | OrderItem[] | yes | قائمة بعناصر الطلب. |
| `price` | Price | yes | تفاصيل السعر. |
| `parcel_details` | ParcelDetails | no | تفاصيل الطرد (موجود فقط إذا كان `type: "parcel"`). |
| `restaurant_info` | object | no | معلومات المطعم (موجود فقط إذا كان `type: "food"`). |
| `created_at` | datetime | yes | وقت إنشاء الطلب. |
| `updated_at` | datetime | yes | وقت آخر تحديث للحالة. |

#### Order Statuses (حالات الطلب)

*   `created`: تم إنشاء الطلب.
*   `confirmed`: تم تأكيد الطلب من قبل النظام/المطعم.
*   `preparing`: جاري إعداد الطلب (خاص بـ Food).
*   `ready_for_pickup`: الطلب جاهز للاستلام من قبل السائق.
*   `in_transit`: الطلب في طريقه للتوصيل.
*   `delivered`: تم توصيل الطلب بنجاح.
*   `canceled`: تم إلغاء الطلب.
*   `failed`: فشل الطلب.

#### Example (Food Order)

```json
{
  "id": "order_456",
  "type": "food",
  "customer_id": "user_456",
  "driver_id": "driver_789",
  "status": "preparing",
  "pickup_address": {
    "lat": 24.7136,
    "lng": 46.6753,
    "address": "Al Baik - Riyadh Front",
    "contact_name": "Restaurant Staff",
    "contact_phone": "+966111234567"
  },
  "dropoff_address": {
    "lat": 24.7743,
    "lng": 46.7386,
    "address": "My Home, Al Olaya",
    "contact_name": "Fahad",
    "contact_phone": "+966509876543"
  },
  "items": [
    {
      "id": "item_1",
      "name": "Chicken Burger",
      "quantity": 1,
      "unit_price": 30.0
    }
  ],
  "price": {
    "currency": "SAR",
    "total_amount": 45.0,
    "delivery_fee": 15.0,
    "items_total": 30.0
  },
  "restaurant_info": {
    "name": "Al Baik",
    "rating": 4.5
  },
  "created_at": "2025-01-01T12:00:00Z",
  "updated_at": "2025-01-01T12:05:00Z"
}
```

---

## 2. نقاط النهاية (Endpoints)

### 2.1. `POST /v1/orders` - إنشاء طلب جديد (Parcel أو Food)

**الوصف:** إنشاء طلب توصيل جديد. يتم تحديد نوع الطلب عبر حقل `type` في جسم الطلب.

**Authentication:** Bearer Token

#### Request Body

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `type` | string | yes | نوع الطلب: `"parcel"` أو `"food"`. |
| `pickup_address` | Address | yes | عنوان الالتقاط. |
| `dropoff_address` | Address | yes | عنوان الإنزال. |
| `items` | OrderItem[] | yes | قائمة بعناصر الطلب. |
| `payment_method_id` | string | yes | معرف طريقة الدفع المختارة. |
| `parcel_details` | ParcelDetails | conditional | مطلوب إذا كان `type: "parcel"`. |
| `restaurant_id` | string | conditional | مطلوب إذا كان `type: "food"`. |

**Example Request (Parcel):**

```json
{
  "type": "parcel",
  "pickup_address": {
    "lat": 24.7136,
    "lng": 46.6753,
    "address": "Office A",
    "contact_name": "Sender",
    "contact_phone": "+966501111111"
  },
  "dropoff_address": {
    "lat": 24.7743,
    "lng": 46.7386,
    "address": "Home B",
    "contact_name": "Receiver",
    "contact_phone": "+966502222222"
  },
  "items": [
    {
      "id": "item_1",
      "name": "Documents",
      "quantity": 1,
      "unit_price": 0.0
    }
  ],
  "parcel_details": {
    "weight_kg": 0.5,
    "dimensions_cm": "10x10x1",
    "category": "Documents"
  },
  "payment_method_id": "card_1234"
}
```

#### Response 200

**الوصف:** إرجاع كيان الطلب المنشأ حديثًا، وستكون حالته الأولية `created`.

**Example Response:**

```json
{
  "order": {
    "id": "order_789",
    "type": "parcel",
    "status": "created",
    "customer_id": "user_456",
    "created_at": "2025-01-01T13:00:00Z",
    "price": {
      "currency": "SAR",
      "total_amount": 25.0,
      "delivery_fee": 25.0,
      "items_total": 0.0
    }
    // ... بقية حقول الطلب
  }
}
```

#### Errors

*   `400 Bad Request`: `invalid_request` (حقول مفقودة أو غير صالحة، أو تفاصيل `parcel_details` مفقودة لطلب طرد).
*   `401 Unauthorized`: `unauthorized`.

### 2.2. `GET /v1/orders/{id}` - استرداد تفاصيل طلب

**الوصف:** استرداد تفاصيل طلب محدد باستخدام معرفه.

**Authentication:** Bearer Token

#### Path Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `id` | string | معرف الطلب (مثال: `order_123`). |

#### Response 200

**الوصف:** إرجاع كيان الطلب (Order) كاملاً.

**Example Response:** (راجع مثال كيان Order في 1.5)

#### Errors

*   `401 Unauthorized`: `unauthorized`.
*   `403 Forbidden`: `forbidden` (الطلب لا يخص المستخدم الحالي).
*   `404 Not Found`: `not_found` (الطلب غير موجود).

### 2.3. `GET /v1/orders` - قائمة الطلبات

**الوصف:** استرداد قائمة بطلبات المستخدم، مع دعم التصفية والترقيم.

**Authentication:** Bearer Token

#### Query Parameters

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `type` | string | no | تصفية حسب نوع الطلب: `"parcel"` أو `"food"`. |
| `status` | string | no | تصفية حسب حالة الطلب (مثال: `delivered`). |
| `cursor` | string | no | مؤشر الترقيم للصفحة التالية (راجع `common_api_conventions.md`). |
| `limit` | integer | no | الحد الأقصى لعدد العناصر في الصفحة (افتراضي 20). |

**Example Request:**

`GET /v1/orders?type=food&status=delivered&limit=10`

#### Response 200

**الوصف:** قائمة بالطلبات المطابقة لمعايير التصفية، مع مؤشر الترقيم.

**Example Response:**

```json
{
  "data": [
    // قائمة بكيانات Order
  ],
  "next_cursor": "def456"
}
```

#### Errors

*   `401 Unauthorized`: `unauthorized`.
*   `400 Bad Request`: `invalid_request` (إذا كانت معلمات الاستعلام غير صالحة).

### 2.4. `POST /v1/orders/{id}/cancel` - إلغاء طلب (اختياري)

**الوصف:** إلغاء طلب نشط.

**Authentication:** Bearer Token

#### Path Parameters

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `id` | string | معرف الطلب المراد إلغاؤه. |

#### Request Body

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `reason` | string | no | سبب الإلغاء. |

#### Response 200

**الوصف:** إرجاع كيان الطلب المحدث، وستكون حالته `canceled`.

**Example Response:**

```json
{
  "order": {
    "id": "order_789",
    "status": "canceled",
    "updated_at": "2025-01-01T13:05:00Z"
    // ... بقية حقول الطلب
  }
}
```

#### Errors

*   `401 Unauthorized`: `unauthorized`.
*   `403 Forbidden`: `forbidden`.
*   `404 Not Found`: `not_found`.
*   `409 Conflict`: `conflict` (إذا كان الطلب في حالة لا يمكن إلغاؤها، مثل `delivered` أو `in_transit`).
