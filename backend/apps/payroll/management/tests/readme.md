# 📋 **DOCUMENTACIÓN DE ENDPOINTS DEL MÓDULO PAYROLL**

Basándome en las pruebas exitosas realizadas, aquí está la documentación completa de los endpoints del módulo de nómina para el desarrollo del frontend:

## 🔐 **AUTENTICACIÓN**

### **Endpoint de Login**
```
POST /api/core/token/
```

**Request Body:**
```json
{
  "email": "testadmin@rhplus.com",
  "password": "testpass123"
}
```

**Response (200):**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Headers para requests autenticados:**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

---

## 👥 **EMPLEADOS**

### **Obtener lista de empleados**
```
GET /api/affiliation/employees/
```

**Response (200):**
```json
[
  {
    "id": 1,
    "first_name": "Juan",
    "last_name": "Pérez",
    "employee_id": "EMP000",
    "email": "juan.perez@company.com"
  }
]
```

---

## 💼 **CONTRATOS**

### **Obtener contratos**
```
GET /api/payroll/contracts/
```

**Response (200):**
```json
[
  {
    "id": 7,
    "employee": 1,
    "salary": "2999203.00",
    "start_date": "2025-01-01",
    "is_active": true
  },
  {
    "id": 8,
    "employee": 7,
    "salary": "1952937.00",
    "start_date": "2025-01-01",
    "is_active": true
  }
]
```

**IDs disponibles en la base de datos:**
- Contract ID 7: Employee 1, Salary $2,999,203.00
- Contract ID 8: Employee 7, Salary $1,952,937.00
- Contract ID 9: Employee 8, Salary $3,351,394.00
- Contract ID 10: Employee 9, Salary $1,963,334.00
- Contract ID 11: Employee 10, Salary $3,198,532.00

---

## 📅 **PERÍODOS DE NÓMINA**

### **Obtener períodos**
```
GET /api/payroll/periods/
```

**Response (200):**
```json
[
  {
    "id": 11,
    "name": "Periodo June 2025",
    "start_date": "2025-06-01",
    "end_date": "2025-06-30",
    "status": "open"
  }
]
```

### **Crear período**
```
POST /api/payroll/periods/
```

**Request Body:**
```json
{
  "name": "Periodo July 2025",
  "start_date": "2025-07-01",
  "end_date": "2025-07-31"
}
```

### **Cerrar período**
```
POST /api/payroll/periods/{id}/close/
```

---

## 📋 **ELEMENTOS DE NÓMINA (PayrollItems)**

### **Obtener elementos de nómina**
```
GET /api/payroll/items/
```

**Response (200):**
```json
[
  {
    "id": 22,
    "name": "Salario Básico",
    "item_type": "EARNING",
    "is_active": true
  },
  {
    "id": 23,
    "name": "Horas Extra",
    "item_type": "EARNING",
    "is_active": true
  },
  {
    "id": 27,
    "name": "Salud (4%)",
    "item_type": "DEDUCTION",
    "is_active": true
  }
]
```

**IDs disponibles en la base de datos:**

**📈 Ingresos (EARNING):**
- ID 22: Salario Básico
- ID 23: Horas Extra
- ID 24: Bonificación
- ID 25: Auxilio de Transporte
- ID 26: Prima de Servicio

**📉 Deducciones (DEDUCTION):**
- ID 27: Salud (4%)
- ID 28: Pensión (4%)
- ID 29: Retención en la Fuente
- ID 30: Préstamo
- ID 31: Descuento por Tardanza

---

## 💰 **ENTRADAS DE NÓMINA (PayrollEntries)**

### **Obtener entradas de nómina**
```
GET /api/payroll/entries/
```

**Response (200):**
```json
[
  {
    "id": 11,
    "employee_name": "Juan Pérez (EMP000)",
    "base_salary": "1952937.00",
    "total_earnings": "2052937.00",
    "total_deductions": "156234.96",
    "net_pay": "1896702.04",
    "status": "pending",
    "approved_by_name": null,
    "approved_at": null,
    "contract": 8,
    "period": 11
  }
]
```

### **Crear entrada de nómina** ⭐
```
POST /api/payroll/entries/
```

**Request Body:**
```json
{
  "employee": 7,
  "contract": 8,
  "period": 11,
  "base_salary": "1952937.00",
  "details": [
    {
      "item_type": "earnings",
      "payroll_item": 22,
      "amount": "1952937.00"
    },
    {
      "item_type": "earnings",
      "payroll_item": 23,
      "amount": "100000.00"
    },
    {
      "item_type": "deductions",
      "payroll_item": 27,
      "amount": "78117.48"
    },
    {
      "item_type": "deductions",
      "payroll_item": 28,
      "amount": "78117.48"
    }
  ]
}
```

**Response (201):**
```json
{
  "id": 11,
  "details": [
    {
      "id": 26,
      "amount": "1952937.00",
      "quantity": "1.00",
      "notes": null,
      "payroll_item": 22
    },
    {
      "id": 27,
      "amount": "100000.00",
      "quantity": "1.00",
      "notes": null,
      "payroll_item": 23
    },
    {
      "id": 28,
      "amount": "78117.48",
      "quantity": "1.00",
      "notes": null,
      "payroll_item": 27
    },
    {
      "id": 29,
      "amount": "78117.48",
      "quantity": "1.00",
      "notes": null,
      "payroll_item": 28
    }
  ],
  "base_salary": "1952937.00",
  "created_at": "2025-05-30T12:16:18.339304-05:00",
  "updated_at": "2025-05-30T12:16:24.133829-05:00",
  "contract": 8,
  "period": 11,
  "created_by": 12
}
```

### **Aprobar entrada de nómina**
```
POST /api/payroll/entries/{id}/approve/
```

**Response (200):**
```json
{
  "id": 11,
  "status": "approved",
  "approved_by_name": "testadmin@rhplus.com",
  "approved_at": "2025-05-30T12:17:50.258931-05:00"
}
```

---

## 🔧 **VALIDACIONES Y RESTRICCIONES**

### **Campos obligatorios para PayrollEntry:**
- `employee` (ID del empleado)
- `contract` (ID del contrato)
- `period` (ID del período)
- `base_salary` (salario base como string decimal)
- `details` (array de detalles)

### **Restricción única:**
- La combinación `(contract, period)` debe ser única
- No se puede crear más de una entrada por contrato en el mismo período

### **Estructura de details:**
```json
{
  "item_type": "earnings" | "deductions",
  "payroll_item": 22,  // ID válido de PayrollItem
  "amount": "1000.00"  // String con formato decimal
}
```

---

## 📊 **EJEMPLOS DE CASOS DE USO**

### **Caso 1: Nómina básica con salario y deducciones**
```json
{
  "employee": 7,
  "contract": 8,
  "period": 11,
  "base_salary": "1952937.00",
  "details": [
    {
      "item_type": "earnings",
      "payroll_item": 22,
      "amount": "1952937.00"
    },
    {
      "item_type": "deductions",
      "payroll_item": 27,
      "amount": "78117.48"
    },
    {
      "item_type": "deductions",
      "payroll_item": 28,
      "amount": "78117.48"
    }
  ]
}
```

### **Caso 2: Nómina con horas extra y bonificaciones**
```json
{
  "employee": 8,
  "contract": 9,
  "period": 11,
  "base_salary": "3351394.00",
  "details": [
    {
      "item_type": "earnings",
      "payroll_item": 22,
      "amount": "3351394.00"
    },
    {
      "item_type": "earnings",
      "payroll_item": 23,
      "amount": "200000.00"
    },
    {
      "item_type": "earnings",
      "payroll_item": 24,
      "amount": "150000.00"
    },
    {
      "item_type": "deductions",
      "payroll_item": 27,
      "amount": "134055.76"
    },
    {
      "item_type": "deductions",
      "payroll_item": 28,
      "amount": "134055.76"
    }
  ]
}
```

---

## ⚠️ **ERRORES COMUNES**

### **Error 400 - Constraint único violado:**
```json
{
  "error": "Error al crear la entrada de nómina",
  "details": "Los campos contract, period deben formar un conjunto único"
}
```

### **Error 400 - PayrollItem inválido:**
```json
{
  "error": "Error al crear la entrada de nómina",
  "details": "Clave primaria \"1\" inválida - objeto no existe"
}
```

### **Error 400 - Campos requeridos:**
```json
{
  "error": "Error al crear la entrada de nómina",
  "details": "Este campo es requerido."
}
```

---

## 🎯 **DATOS DISPONIBLES PARA PRUEBAS**

**Usuarios activos:**
- testadmin@rhplus.com (password: testpass123)

**Empleados disponibles:**
- Employee IDs: 1, 7, 8, 9, 10

**Contratos activos:**
- Contract IDs: 7, 8, 9, 10, 11

**Períodos disponibles:**
- Period ID: 11 (June 2025)

**PayrollItems disponibles:**
- Ingresos: IDs 22-26
- Deducciones: IDs 27-31

Esta documentación está basada en pruebas exitosas y refleja el estado actual y funcional del sistema.