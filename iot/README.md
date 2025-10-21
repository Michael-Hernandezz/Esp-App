📱 PROYECTO IOT SMART HOME
├── 🏠 main.dart (Punto de entrada)
│   └── SmartHomeApp
│
├── 🏗️ CORE (Funcionalidades básicas)
│   ├── 📱 app/
│   │   └── app.dart (Configuración principal de la app)
│   │
│   ├── 🔧 shared/ (Componentes compartidos)
│   │   ├── 📊 data/services/ (Servicios de datos)
│   │   ├── 🏛️ domain/entities/ (Entidades del dominio)
│   │   └── 🎨 presentation/ (Componentes UI compartidos)
│   │       ├── providers/ (Gestores de estado)
│   │       ├── services/ (Servicios de presentación)
│   │       └── widgets/ (Widgets reutilizables)
│   │
│   └── 🎨 theme/ (Temas y estilos)
│       ├── sh_colors.dart
│       ├── sh_icons.dart
│       └── sh_theme.dart
│
└── 🏢 FEATURES (Funcionalidades específicas)
    ├── 🏠 home/ (Pantalla principal)
    │   └── presentation/screens/
    │
    ├── 📊 dashboard/ (Dashboard de control)
    │   └── presentation/screens/
    │       └── enhanced_dashboard_screen.dart
    │
    ├── 🏠 smart_room/ (Habitaciones inteligentes)
    │   ├── screens/
    │   └── widgets/
    │
    ├── ⚙️ automations/ (Automatizaciones)
    │   └── presentation/screens/
    │
    ├── 🔔 notifications/ (Notificaciones)
    │   └── presentation/screens/
    │
    ├── 📈 history/ (Historial)
    │   └── presentation/screens/
    │
    └── ⚙️ settings/ (Configuraciones)
        └── presentation/screens/

┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    HOME     │────│  DASHBOARD  │────│ SMART_ROOM  │
│   /home     │    │ /dashboard  │    │             │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                    ┌─────────────┐
                    │ NAVIGATION  │
                    │   HUB       │
                    └─────────────┘
                           │
       ┌───────────────────┼───────────────────┐
       │                   │                   │
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│AUTOMATIONS  │    │NOTIFICATIONS│    │  HISTORY    │
│/automations │    │/notifications│   │  /history   │
└─────────────┘    └─────────────┘    └─────────────┘
                           │
                    ┌─────────────┐
                    │  SETTINGS   │
                    │ /settings   │
                    └─────────────┘


┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │
│  │   Screens   │ │   Widgets   │ │  Providers  │        │
│  └─────────────┘ └─────────────┘ └─────────────┘        │
├─────────────────────────────────────────────────────────┤
│                    DOMAIN LAYER                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │
│  │  Entities   │ │ Use Cases   │ │ Repositories│        │ 
│  └─────────────┘ └─────────────┘ └─────────────┘        │
├─────────────────────────────────────────────────────────┤
│                     DATA LAYER                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │
│  │  Services   │ │  Data Src   │ │   Models    │        │
│  └─────────────┘ └─────────────┘ └─────────────┘        │
└─────────────────────────────────────────────────────────┘