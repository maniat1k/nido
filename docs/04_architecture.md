# Nido — Arquitectura Base

## 1. Objetivo de esta arquitectura

Definir una base técnica simple, clara y mantenible para construir el MVP de Nido en Flutter, evitando sobreingeniería en etapas tempranas.

La arquitectura debe permitir:

- Avanzar rápido
- Mantener orden en el código
- Facilitar cambios
- Permitir que otra persona o una IA entienda el proyecto sin reconstruir el contexto desde cero

---

## 2. Stack principal

### Frontend
- Flutter

### Lenguaje
- Dart

### Plataforma objetivo inicial
- Mobile first

### Fuente de datos en etapa MVP
- Datos mock / locales

---

## 3. Principios técnicos

### 3.1 Simplicidad
Se prioriza una estructura simple y comprensible antes que una arquitectura excesivamente abstracta.

### 3.2 Separación de responsabilidades
La UI no debe concentrar toda la lógica.  
Se busca separar:

- modelos
- datos
- lógica de presentación
- pantallas
- componentes reutilizables

### 3.3 Escalabilidad gradual
La arquitectura debe permitir comenzar con datos mock y luego migrar a persistencia real sin reescribir toda la app.

### 3.4 Reutilización
Los componentes visuales repetidos deben centralizarse.

---

## 4. Estructura sugerida del proyecto

```text
lib/
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme/
│       └── app_theme.dart
│
├── core/
│   ├── constants/
│   ├── utils/
│   └── helpers/
│
├── data/
│   ├── models/
│   │   └── garment.dart
│   ├── repositories/
│   │   └── garment_repository.dart
│   └── sources/
│       └── mock_garments.dart
│
├── features/
│   ├── home/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── controllers/
│   │
│   ├── publish/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── controllers/
│   │
│   └── detail/
│       ├── screens/
│       ├── widgets/
│       └── controllers/
│
├── shared/
│   ├── widgets/
│   └── layouts/
│
└── main.dart