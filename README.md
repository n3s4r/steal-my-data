# 🎓 UniFriends

A modern University Friend-making app built with **Flutter** and **Supabase**, designed to help students connect based on shared interests, university, and academic journey.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-0553B1?style=for-the-badge&logo=dart&logoColor=white)

## ✨ Features

- **🔐 Authentication** - Email/password and Google sign-in via Supabase Auth
- **👤 Profile Management** - Create and customize your profile with avatar, bio, and interests
- **🔍 Discovery** - Find students with similar interests or from the same university
- **👥 Friend System** - Send, accept, and manage friend requests with real-time updates
- **🎨 Beautiful Dark UI** - Modern, coral-accented dark theme with smooth animations

## 🏗️ Architecture

This project follows **Clean Architecture** with a feature-based structure:

```
lib/
├── core/
│   ├── constants/       # App constants
│   ├── error/           # Failures & exceptions
│   ├── network/         # Supabase client
│   ├── router/          # GoRouter configuration
│   ├── theme/           # App theme & colors
│   ├── utils/           # Utilities & type definitions
│   └── widgets/         # Shared widgets
│
└── features/
    ├── auth/
    │   ├── data/        # Data sources & repository impl
    │   ├── domain/      # Entities & repository interfaces
    │   └── presentation/# Screens, providers, widgets
    │
    ├── profile/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── friends/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    └── discover/
        ├── data/
        ├── domain/
        └── presentation/
```

## 📱 Screens

| Discover | Friends | Profile |
|----------|---------|---------|
| Browse recommended profiles | Manage friend requests | View and edit your profile |
| Filter by interests | Real-time notifications | Set interests and bio |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK >= 3.2.0
- Supabase account
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/uni-friends.git
cd uni-friends
```

### 2. Set Up Supabase

1. Create a new project at [supabase.com](https://supabase.com)

2. Run the database schema:
   - Go to SQL Editor in your Supabase dashboard
   - Copy and paste contents of `supabase/schema.sql`
   - Run the query

3. Create Storage Buckets:
   - Go to Storage in your dashboard
   - Create a bucket named `avatars` (public)

4. Configure Authentication:
   - Enable Email authentication
   - (Optional) Enable Google OAuth

### 3. Configure Environment

Create a `.env` file in the project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

Or pass them as compile-time variables:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-key
```

### 4. Add Fonts

Download the [Outfit font](https://fonts.google.com/specimen/Outfit) and place the files in `assets/fonts/`:

- Outfit-Regular.ttf
- Outfit-Medium.ttf
- Outfit-SemiBold.ttf
- Outfit-Bold.ttf

### 5. Install Dependencies

```bash
flutter pub get
```

### 6. Run the App

```bash
flutter run
```

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `supabase_flutter` | Backend integration |
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `fpdart` | Functional programming utilities |
| `cached_network_image` | Image caching |
| `flutter_animate` | Animations |

## 🗃️ Database Schema

### Tables (snake_case convention)

- **universities** - List of universities
- **interests** - Interest categories (sports, arts, tech, etc.)
- **profiles** - User profiles linked to auth.users
- **user_interests** - Junction table for user interests
- **friend_requests** - Pending, accepted, or rejected requests
- **friendships** - Bidirectional friend relationships
- **conversations** - Chat conversations (future feature)
- **messages** - Chat messages (future feature)

### Row Level Security

All tables have RLS policies configured for:
- Users can only view and manage their own data
- Public profiles are viewable by authenticated users
- Friend requests visible only to sender/receiver

## 🔧 Code Conventions

- **Database**: `snake_case` for table/column names
- **Dart**: `camelCase` for variables and functions
- **Models**: Handle conversion between naming conventions
- **Error Handling**: All Supabase calls wrapped with `SupabaseErrorHandler`

## 📁 Project Structure Details

### Core Layer
- **Error Handling**: `Failure` classes for domain errors, `Exception` classes for data layer
- **Type Definitions**: `ResultFuture<T>` = `Future<Either<Failure, T>>`
- **Supabase Error Handler**: Wraps all database operations with proper error mapping

### Domain Layer
- **Entities**: Pure Dart classes representing business objects
- **Repositories**: Abstract interfaces defining data operations

### Data Layer
- **Models**: Extend entities with JSON serialization
- **Data Sources**: Direct Supabase API calls
- **Repository Implementations**: Implement domain interfaces with error handling

### Presentation Layer
- **Riverpod Providers**: State management with dependency injection
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components

## 🎨 Theming

The app uses a custom dark theme with:
- **Primary**: Coral (#FF6B6B)
- **Accent**: Electric Teal (#00D9C0)
- **Secondary**: Deep Violet (#6C5CE7)
- **Background**: Dark Navy (#0D0D1A)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Built with ❤️ using Flutter & Supabase
