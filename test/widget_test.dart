import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nalaseva/features/auth/widgets/auth_submit_button.dart';
import 'package:nalaseva/features/auth/widgets/auth_gender_button.dart';
import 'package:nalaseva/features/auth/widgets/auth_text_field.dart';
import 'package:nalaseva/features/auth/logic/auth_provider.dart';
import 'package:nalaseva/features/auth/data/auth_repository.dart';
import 'package:nalaseva/core/services/firebase_messaging_service.dart';
import 'package:nalaseva/shared/models/user_model.dart';
import 'package:nalaseva/features/auth/ui/login_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AuthSubmitButton Widget Tests', () {
    testWidgets('Should display label and invoke onPressed when not loading', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthSubmitButton(
              label: 'Submit Test',
              isLoading: false,
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Submit Test'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(AuthSubmitButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('Should display loading indicator and not invoke onPressed when loading', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthSubmitButton(
              label: 'Submit Test',
              isLoading: true,
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit Test'), findsNothing);

      await tester.tap(find.byType(AuthSubmitButton));
      await tester.pump();

      expect(pressed, isFalse);
    });
  });

  group('AuthGenderButton Widget Tests', () {
    testWidgets('Should display label, icon, and call onTap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthGenderButton(
              label: 'Male',
              icon: Icons.male,
              isSelected: true,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Male'), findsOneWidget);
      expect(find.byIcon(Icons.male), findsOneWidget);

      await tester.tap(find.byType(AuthGenderButton));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });

  group('AuthTextField Widget Tests', () {
    testWidgets('Should enter text and toggle password visibility', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              controller: controller,
              label: 'Password',
              hintText: 'Enter password',
              icon: Icons.lock,
              isPassword: true,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'myPassword123');
      expect(controller.text, 'myPassword123');

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      final textFieldUnobscured = tester.widget<TextField>(find.byType(TextField));
      expect(textFieldUnobscured.obscureText, isFalse);
    });
  });

  group('Responsive LoginScreen Layout Tests', () {
    late DummyAuthRepository dummyRepository;
    late DummyFirebaseMessagingService dummyFcmService;
    late AuthProvider dummyAuthProvider;

    setUp(() {
      dummyRepository = DummyAuthRepository();
      dummyFcmService = DummyFirebaseMessagingService();
      dummyAuthProvider = AuthProvider(dummyRepository, dummyFcmService);
    });

    Future<void> configureScreen(WidgetTester tester, double width, double height) async {
      final size = Size(width, height);
      await tester.binding.setSurfaceSize(size);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
    }

    testWidgets('Should render properly on Smartphone viewport (360x800) without large screen layout features', (WidgetTester tester) async {
      await configureScreen(tester, 360, 800);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: dummyAuthProvider,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsAtLeastNWidgets(1));

      expect(find.byType(AuthTextField), findsNWidgets(2));
      expect(find.text('Selamat Datang'), findsOneWidget);
    });

    testWidgets('Should render properly on Tablet viewport (768x1024) utilizing the large screen layout features', (WidgetTester tester) async {
      await configureScreen(tester, 768, 1024);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: dummyAuthProvider,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AuthTextField), findsNWidgets(2));
      expect(find.text('Selamat Datang'), findsOneWidget);

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Form),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.constraints?.maxWidth, 500.0);
    });

    testWidgets('Should render properly on Android TV viewport (1920x1080) utilizing the widescreen layout features', (WidgetTester tester) async {
      await configureScreen(tester, 1920, 1080);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: dummyAuthProvider,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AuthTextField), findsNWidgets(2));
      expect(find.text('Selamat Datang'), findsOneWidget);

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Form),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.constraints?.maxWidth, 500.0);
    });
  });
}

class DummyAuthRepository implements AuthRepository {
  @override
  Future<Map<String, dynamic>> login(String email, String password) async => {};
  @override
  Future<void> register({required String name, required String email, required String password, required String phone, required String address, required String nationalId, required String gender, required String birthDate}) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> updateFcmToken(String token) async {}
  @override
  Future<UserModel> updateProfile({String? name, String? email, String? phone, String? address, String? nationalId, String? gender, String? birthDate}) async => UserModel(id: 1, name: '', email: '', role: '');
  @override
  Future<UserModel> getProfile() async => UserModel(id: 1, name: '', email: '', role: '');
  @override
  Future<String?> requestPasswordResetOtp(String email, String nationalId) async => null;
  @override
  Future<void> forgotPassword(String email, String nationalId, String otpCode, String newPassword) async {}
}

class DummyFirebaseMessagingService implements FirebaseMessagingService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasNotificationPermission() async => true;

  @override
  Future<String?> getFCMToken() async => 'mocked_token';

  @override
  Future<void> showLocalNotification(RemoteMessage message) async {}
}


