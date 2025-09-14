# 🎱 Sabo Arena - Billiards Tournament Management App

## 📱 Tổng quan
Sabo Arena là ứng dụng quản lý giải đấu Billiards được xây dựng bằng Flutter và Firebase. Ứng dụng hỗ trợ quản lý câu lạc bộ, tổ chức giải đấu, thách đấu, và theo dõi thống kê người chơi.

## ✨ Tính năng chính

### 👤 Quản lý Người dùng
- Đăng ký/Đăng nhập với Firebase Auth
- Profile cá nhân với thống kê chi tiết
- Hệ thống ELO rating
- Thành tích và bảng xếp hạng

### 🏢 Quản lý Câu lạc bộ
- Tạo và quản lý câu lạc bộ
- Thành viên và nhân viên
- Đánh giá và review
- Quản lý bàn bida

### 🏆 Giải đấu
- Tạo và tham gia giải đấu
- Nhiều định dạng: Single/Double Elimination, Round Robin
- Quản lý lịch thi đấu
- Phân phối giải thưởng

### 🎯 Thách đấu
- Gửi lời thách đấu
- Chấp nhận/Từ chối thách đấu
- Theo dõi kết quả trận đấu
- Cập nhật ELO rating tự động

### 📊 Thống kê
- Thống kê chi tiết từng loại game
- Biểu đồ phong độ
- Lịch sử trận đấu
- Leaderboard theo nhiều tiêu chí

### 💬 Giao tiếp
- Hệ thống chat
- Thông báo push
- Tin nhắn trong app

## 🚀 Công nghệ sử dụng

### Frontend
- **Flutter** - Framework UI đa nền tảng
- **Dart** - Ngôn ngữ lập trình
- **FlutterFlow** - UI builder tools

### Backend
- **Firebase Auth** - Xác thực người dùng
- **Cloud Firestore** - NoSQL database
- **Cloud Functions** - Serverless functions
- **Firebase Storage** - Lưu trữ media
- **Cloud Messaging** - Push notifications

### Kiến trúc
- **MVC Pattern** - Tách biệt logic và UI
- **Provider Pattern** - State management
- **Repository Pattern** - Data access layer

## 📦 Collections Database

### Core Collections
- `users` - Thông tin người dùng
- `clubs` - Câu lạc bộ
- `tournaments` - Giải đấu
- `matches` - Trận đấu
- `challenges` - Thách đấu

### Support Collections
- `player_statistics` - Thống kê chi tiết
- `leaderboards` - Bảng xếp hạng
- `notifications` - Thông báo
- `transactions` - Giao dịch
- `push_tokens` - Push notification tokens

## 🛠️ Setup và Development

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Firebase CLI
- Android Studio / VS Code
- Git

### Installation
```bash
# Clone repository
git clone <repository-url>
cd sabo_arena

# Install dependencies
flutter pub get

# Firebase setup
firebase login
firebase init

# Run app
flutter run
```

### Firebase Functions
```bash
cd firebase/functions
npm install
firebase deploy --only functions
```

## 🏗️ Cấu trúc Project

```
lib/
├── auth/                 # Authentication logic
├── backend/             # Firebase backend integration
│   ├── schema/         # Firestore document models
│   ├── firebase/       # Firebase services
│   └── firebase_storage/ # Storage services
├── components/          # Reusable UI components
├── flutter_flow/        # FlutterFlow generated code
├── pages/              # App screens/pages
└── main.dart           # App entry point

firebase/
├── functions/          # Cloud Functions
├── firestore.rules     # Security rules
├── firestore.indexes.json # Database indexes
└── firebase.json      # Firebase config
```

## 🎮 Game Types Support
- **8-Ball Pool** - Game bi-da 8 bi phổ biến
- **9-Ball Pool** - Game bi-da 9 bi chuyên nghiệp  
- **10-Ball Pool** - Biến thể nâng cao
- **Snooker** - Bi-da Anh truyền thống

## 📈 Enhanced Features

### ELO Rating System
- Tự động tính toán rating sau mỗi trận
- K-factor điều chỉnh theo level
- Lịch sử thay đổi rating

### Tournament Management
- Bracket tự động
- Seeding thông minh
- Live scoring
- Prize pool management

### Analytics Dashboard
- Performance metrics
- Win/Loss trends
- Shot accuracy tracking
- Match duration analysis

## 🔧 Development Status

- [x] ✅ Core Firebase setup
- [x] ✅ Enhanced schema design
- [x] ✅ Cloud Functions implementation
- [x] ✅ Authentication system
- [ ] 🚧 Sample data generation
- [ ] 🚧 UI enhancements
- [ ] 📋 Testing & QA
- [ ] 🚀 Production deployment

## 👥 Team
- **Lead Developer**: Sabo Arena Team
- **Backend**: Firebase & Cloud Functions
- **Frontend**: Flutter & FlutterFlow
- **Design**: Material Design 3

## 📄 License
This project is licensed under the MIT License.

## 🤝 Contributing
Contributions are welcome! Please read our contributing guidelines before submitting PRs.

---
*Built with ❤️ for the Billiards community*

## Getting Started

FlutterFlow projects are built to run on the Flutter _stable_ release.
